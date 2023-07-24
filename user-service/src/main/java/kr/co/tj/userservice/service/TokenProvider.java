package kr.co.tj.userservice.service;

import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import kr.co.tj.userservice.dto.UserEntity;
import kr.co.tj.userservice.dto.UserRole;

@Component // 스프링 컨텍스트에서 빈으로 등록
public class TokenProvider {

	@Autowired
	private Environment env; // application.yml 파일에서 data.SECRET_KEY값 가져옴

	// JWT 토큰 생성
	public String create(UserEntity userEntity) {

		// 현재 시간을 기준으로 토큰의 발급일과 만료일 설정
		long now = System.currentTimeMillis();

		Date today = new Date(now); // 발급일
		Date exireDate = new Date(now + 1000 * 1 * 60 * 60 * 24); // 만료일

		// Jwts.builder()를 사용하여 토큰을 생성하고, 암호화 알고리즘과 비밀키를 지정
		return Jwts.builder()
				.signWith(SignatureAlgorithm.HS512, env.getProperty("data.SECRET_KEY"))
				.setSubject(userEntity.getUsername()).setIssuer("user-service")
				.setIssuedAt(today)
				.setExpiration(exireDate)
				.claim("role", userEntity.getRole().name()) // "role"이라는 이름의 역할 설정 후 열거형 상수 이름으로 설정
				.compact(); // 토큰 최종 생성 및 문자열 반환
	}

	// 토큰에서 사용자명 추출
	public String getUsernameFromToken(String token) {
		Claims claims = Jwts.parser()
				.setSigningKey(env.getProperty("data.SECRET_KEY")) // 암호화 알고리즘과 비밀키 설정
				.parseClaimsJws(token) // 토큰을 파싱하고 본문(Claims) 반환
				.getBody(); // 토큰의 본문에서 사용자명 추출

		return claims.getSubject(); // 추출한 사용자명 반환
	}

	// 토큰에서 사용자 역할 추출
	public UserRole getRoleFromToken(String token) {
		Claims claims = Jwts.parser()
				.setSigningKey(env.getProperty("data.SECRET_KEY"))
				.parseClaimsJws(token)
				.getBody();

		String role = claims.get("role", String.class); // 토큰 본문에서 "role"이라는 이읆의 값 추출하여 String형태로 반환

		// 추출 역할 값이 null일 경우 예외 처리
		if (role == null) {
			throw new RuntimeException("토큰오류.");
		}

		return UserRole.valueOf(role); // 추출한 role값을 UserRole 열거형 상수로 반환
	}

}
