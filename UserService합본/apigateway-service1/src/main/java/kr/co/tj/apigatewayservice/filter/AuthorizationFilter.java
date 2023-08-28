package kr.co.tj.apigatewayservice.filter;

import java.util.Base64;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;

import io.jsonwebtoken.Jwts;

import reactor.core.publisher.Mono;

@Component // AbstractGatewayFilterFactory를 상속해 Gateway 필터 팩토리로 동작하도록 함
public class AuthorizationFilter extends AbstractGatewayFilterFactory<AuthorizationFilter.Config> {

	private Environment env; // application.yml 파일에서 data.SECRET_KEY 값을 가져옴

	@Autowired
	public AuthorizationFilter(Environment env) {
		super(Config.class);
		this.env = env;
	}

	// @Data
	public static class Config {
	}

	@Override
	public GatewayFilter apply(Config config) {

		return (exchange, chain) -> {
			// 반드시 reacitve 붙은 패키지명 확인하고 넣기
			ServerHttpRequest request = exchange.getRequest();

			if (!request.getHeaders().containsKey(HttpHeaders.AUTHORIZATION)) {
				return onError(exchange, "authorization 키가 없습니다.", HttpStatus.UNAUTHORIZED);
			}

			// 들어오는 요청의 헤더에 Authorization 키가 없는 경우, 즉 인증 토큰이 없는 경우에는 UNAUTHORIZED 상태로 처리
			// 들어오는 요청의 헤더에서 Authorization 키를 추출하여 Bearer 토큰을 가져옴
			String bearerToken = request.getHeaders().get(HttpHeaders.AUTHORIZATION).get(0);

			// 토큰에서 "Bearer " 부분을 제거하여 실제 토큰 문자열을 얻기
			String token = bearerToken.replace("Bearer ", "");

			// 추출한 토큰을 isJwtValid 메서드로 검증하여 유효한지 확인
			if (!isJwtValid(token)) {
				return onError(exchange, "토큰이 유효하지 않습니다..", HttpStatus.UNAUTHORIZED);
			}

			return chain.filter(exchange);
		};
	}

	// 주어진 토큰이 유효한지 확인
	private boolean isJwtValid(String token) {

		boolean isValid = true; // 유효성 초기값을 true로 설정
		String subject = null; // 토큰에서 추출한 사용자명을 저장할 변수를 초기화

		String str = env.getProperty("data.SECRET_KEY");

		// SECRET_KEY 값이 없는 경우 예외를 발생
		if (str == null) {
			throw new RuntimeException("SECRET_KEY 오류");
		}

		// SECRET_KEY 값을 Base64로 인코딩
		// Base64 : 데이터를 문자열로 인코딩하고 디코딩하는 방식 중 하나(인코딩된 문자열을 일반 문자열로 처리)
		String encodedStr = Base64.getEncoder().encodeToString(str.getBytes());

		try {
			// 토큰을 파싱하고, 본문(Claims)에서 사용자명을 추출
			subject = Jwts.parser().setSigningKey(str).parseClaimsJws(token).getBody().getSubject();

		} catch (Exception e) {
			e.printStackTrace();
			isValid = false; // 파싱 도중 예외가 발생한 경우 유효성을 false로 설정
		}

		// 추출한 사용자명이 비어있는 경우 유효성을 false로 설정
		if (subject == null || subject.isEmpty()) {
			isValid = false;
		}

		// 유효성 여부를 반환
		return isValid;
	}

	// 오류 응답 생성
	private Mono<Void> onError(ServerWebExchange exchange, String string, HttpStatus status) {
		ServerHttpResponse response = exchange.getResponse();
		response.setStatusCode(status);

		return response.setComplete();
	}

}
