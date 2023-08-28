package kr.co.tj.userservice.controller;

import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.co.tj.userservice.dto.UserDTO;
import kr.co.tj.userservice.dto.UserLoginRequest;
import kr.co.tj.userservice.dto.UserPassRequest;
import kr.co.tj.userservice.dto.UserRequest;
import kr.co.tj.userservice.dto.UserResponse;
import kr.co.tj.userservice.dto.UserRole;
import kr.co.tj.userservice.dto.UserRoleRequest;
import kr.co.tj.userservice.service.TokenProvider;
import kr.co.tj.userservice.service.UserServiceImpl;

@RestController
@RequestMapping("/user-service")
public class UserController {

	private Environment env; // 환경설정을 위한 필드

	private BCryptPasswordEncoder passwordEncoder;

	private UserServiceImpl userService;

	private TokenProvider tokenProvider;

	@Autowired
	public UserController(Environment env, BCryptPasswordEncoder passwordEncoder, UserServiceImpl userService,
			TokenProvider tokenProvider) {
		super();
		this.env = env;
		this.passwordEncoder = passwordEncoder;
		this.userService = userService;
		this.tokenProvider = tokenProvider;
	}

	// 로그인
	@PostMapping("/login")
	public ResponseEntity<?> login(@RequestBody UserLoginRequest userLoginRequest) {
		Map<String, Object> map = new HashMap<>();

		// username 비어있으면 안됨
		if (userLoginRequest.getUsername() == null || userLoginRequest.getUsername().isEmpty()) {
			map.put("result", "아이디 공백"); // 비어있을 경우 에러메세지 설정
			return ResponseEntity.ok().body(map);
		}

		// password 비어있으면 안됨
		if (userLoginRequest.getPassword() == null || userLoginRequest.getPassword().isEmpty()) {
			map.put("result", "비밀번호 공백"); // 비어있을 경우 에러메시지 설정
			return ResponseEntity.ok().body(map);
		}

		UserDTO userDTO = UserDTO.toUserDTO(userLoginRequest);

		userDTO = userService.login(userDTO);

		if (userDTO == null) {
			map.put("result", "오류발생. 다시 시도해주세요."); // 로그인 서비스 호출오류 발생 시 에러메세지 설정
			return ResponseEntity.ok().body(map);
		}

		UserResponse userResponse = userDTO.toUserResponse();
		map.put("result", userResponse); // 로그인 성공시 사용자 정보를 담은 응답 객체 설정
		return ResponseEntity.ok().body(map);
	}

	// 회원가입
	@PostMapping("/insert")
	public ResponseEntity<?> createUser(@RequestBody UserRequest userRequest) {

		// 입력된 두 개의 비밀번호가 일치하는지 확인
		if (!userRequest.getPassword().equals(userRequest.getPassword2())) {
			// 두 비밀번호가 일치하지 않는 경우, 400(Bad Request) 상태 코드와 함께 에러 메시지를 반환
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("비밀번호가 일치하지 않습니다.");
		}

		// 비밀번호 최소 6자 이상 입력 검증
		if (userRequest.getPassword().length() < 6) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("비밀번호는 최소 6자 이상 입력해야 합니다.");
		}

		// 아이디 최소 4자 이상 입력 검증
		if (userRequest.getUsername().length() < 4) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("아이디는 최소 4자 이상 입력해야 합니다.");
		}

		// 닉네임 최소 2자 이상 입력 검증
		if (userRequest.getNickname().length() < 2) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("닉네임은 최소 2자 이상 입력해야 합니다.");
		}

		// 닉네임 최대 20자 이하 입력 검증
		if (userRequest.getNickname().length() > 20) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("닉네임은 최대 20자까지 입력 가능합니다.");
		}

		// 받아온 UserRequest 객체를 UserDTO로 변환
		UserDTO userDTO = UserDTO.toUserDTO(userRequest);

		try {
			// userService의 createUser 메서드 사용하여 사용자 생성
			userDTO = userService.createUser(userDTO);
		} catch (RuntimeException e) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}

		// 생성된 UserDTO를 UserResponse로 변환
		UserResponse userResponse = userDTO.toUserResponse();

		// http 상태코드 201(CREATED)과 생성된 사용자 정보 반환
		return ResponseEntity.status(HttpStatus.CREATED).body(userResponse);
	}

	// 사용자 목록 (페이징x)
	@GetMapping("/all")
	public ResponseEntity<?> getUsers() {

		// userService의 getUsers 메서드를 사용하여 모든 사용자 정보 가져옴
		List<UserDTO> userDTOs = userService.getUsers();
		// UserDTO 리스트를 UserResponse로 변환, 리스트로 만듦
		List<UserResponse> userResponses = userDTOs.stream().map(UserDTO::toUserResponse).collect(Collectors.toList());

		// http 상태코드 200(OK)과 사용자 정보 리스트를 반환
		return ResponseEntity.status(HttpStatus.OK).body(userResponses);
	}

	// 사용자 목록 날짜로 검색
	@GetMapping("/search-date")
	public ResponseEntity<?> list(@RequestParam("pageNum") int pageNum, @RequestParam("startDate") String startDate,
			@RequestParam("endDate") String endDate) {

		// 응답 데이터를 담기 위한 Map 객체 생성
		Map<String, Object> map = new HashMap<>();

		// UserService의 findAll 메서드를 호출하여 사용자 목록 조회
		Page<UserDTO> page = userService.findAll(pageNum, startDate, endDate);

		// 조회 결과를 "result"라는 키로 Map에 저장
		map.put("result", page);

		// 조회 결과를 반환
		return ResponseEntity.ok().body(map);
	}

	// 목록 페이징
	@GetMapping("/list")
	public ResponseEntity<?> getUsers(@RequestParam(required = false, defaultValue = "0") int page,
			@RequestParam(required = false, defaultValue = "20") int size) {

		// userService의 getPagingUsers 메서드를 사용하여 페이지네이션된 사용자 정보를 가져옴
		// Sort를 이용해 username에 대해 오름차순으로 정렬
		Page<UserDTO> userDTOs = userService
				.getPagingUsers(PageRequest.of(page, size, Sort.by("username").ascending()));
		// 페이지네이션된 UserDTO 리스트를 UserResponse로 변환하고 리스트 생성
		List<UserResponse> userResponses = userDTOs.getContent().stream().map(UserDTO::toUserResponse)
				.collect(Collectors.toList());

		// 응답에 필요한 사용자 정보와 페이지네이션 정보를 담은 맵 생성
		Map<String, Object> response = new HashMap<>();
		response.put("users", userResponses);
		response.put("currentPage", userDTOs.getNumber());
		response.put("totalItems", userDTOs.getTotalElements());
		response.put("totalPages", userDTOs.getTotalPages());

		// http 상태코드 200(OK)과 Map 반환
		return ResponseEntity.status(HttpStatus.OK).body(response);
	}

	// 정보 상세보기 ( 관리자와 본인만 볼 수 있음. 아이디, 이름, 이메일, 생일, 권한, 가입일, 갱신일 )
	@GetMapping("/detail/{username}")
	public ResponseEntity<?> getUser(@RequestHeader(value = "Authorization") String token,
			@PathVariable("username") String username) {

		token = token.substring(7); // "Bearer " 삭제
		String userFromToken = tokenProvider.getUsernameFromToken(token); // 토큰에서 사용자의 username 추출
		UserRole roleFromToken = tokenProvider.getRoleFromToken(token); // 토큰에서 사용자의 role 추출
		// 토큰의 사용자와 URL의 사용자가 같거나 관리자인지 확인
		if (!username.equals(userFromToken) && !roleFromToken.equals(UserRole.TYPE2)) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body("접근 권한이 없습니다.");
		}

		// userService의 getUser 메서드를 사용해 사용자 정보 가져옴
		UserDTO userDTO = userService.getUser(username);
		// UserDTO를 UserResponse로 변환
		UserResponse userResponse = userDTO.toUserResponse();

		// http 상태코드 200(OK)과 사용자 정보 반환
		return ResponseEntity.status(HttpStatus.OK).body(userResponse);
	}

	// 프로필 ( 공개 프로필. 아이디, 이름, 이메일, 생일, 가입일, 내가 쓴 글/댓글 목록 )
	@GetMapping("/profile/{username}")
	public ResponseEntity<?> getUserProfile(@RequestHeader(value = "Authorization", required = false) String token,
			@PathVariable("username") String username) {

		// 토큰이 없으면 로그인하지 않은 사용자이므로 거부
		if (token == null || token.isEmpty()) {
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("로그인이 필요합니다.");
		}

		token = token.substring(7); // "Bearer " 삭제
		UserRole roleFromToken = tokenProvider.getRoleFromToken(token); // 토큰에서 사용자의 role 추출

		// 토큰의 사용자의 역할이 TYPE3이면 프로필을 볼 수 없음
		if (roleFromToken.equals(UserRole.TYPE3)) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body("접근 권한이 없습니다.");
		}

		// userService의 getUser 메서드를 사용해 사용자 정보 가져옴
		UserDTO userDTO = userService.getUser(username);
		// UserDTO를 UserResponse로 변환
		UserResponse userResponse = userDTO.toUserResponse();

		// http 상태코드 200(OK)과 사용자 정보 반환
		return ResponseEntity.status(HttpStatus.OK).body(userResponse);
	}

	// 수정 (username값 고정. 이름, 이메일, 생일 수정 가능)
	@PutMapping("/update/{username}")
	public ResponseEntity<?> updateUser(@RequestHeader(value = "Authorization") String token,
			@PathVariable("username") String username, @RequestBody UserRequest userRequest) {

		// Bearer 삭제하고 토큰에서 username 추출
		String userFromToken = tokenProvider.getUsernameFromToken(token.substring(7));
		// 토큰의 사용자와 URL의 사용자가 같은지 확인
		if (!username.equals(userFromToken)) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body("접근 권한이 없습니다.");
		}

		try {
			// 로그인한 사용자와 수정하려는 회원이 같은지 확인
			if (!userRequest.getUsername().equals(username)) {
				throw new RuntimeException("접근 권한이 없습니다.");
			}

			// userService의 updateUser 메서드를 사용해 사용자 정보 업데이트
			userRequest = userService.updateUser(username, userRequest);
			// http 상태코드 200(OK)과 업데이트 된 사용자 정보 반환
			return ResponseEntity.status(HttpStatus.OK).body(userRequest);

			// 업데이트 실패시 http 상태코드 400(BAD_REQUEST)과 에러메세지 반환
		} catch (RuntimeException e) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("error");
		}
	}

	// 비밀번호 수정
	@PutMapping("/update-pass/{username}")
	public ResponseEntity<?> updatePass(@RequestHeader(value = "Authorization") String token,
			@PathVariable("username") String username, @RequestBody UserPassRequest userPass) {

		// Bearer 삭제하고 토큰에서 username 추출
		String userFromToken = tokenProvider.getUsernameFromToken(token.substring(7));
		// 토큰의 사용자와 URL의 사용자가 같은지 확인
		if (!username.equals(userFromToken)) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body("접근 권한이 없습니다.");
		}

		try {
			// 로그인한 사용자와 수정하려는 회원이 같은지 확인
			if (!userPass.getUsername().equals(username)) {
				throw new RuntimeException("접근 권한이 없습니다.");
			}

			// userService의 updateUser 메서드를 사용해 사용자 정보 업데이트
			userPass = userService.updatePass(username, userPass);
			// http 상태코드 200(OK)과 업데이트 된 사용자 정보 반환
			return ResponseEntity.status(HttpStatus.OK).body(userPass);

			// 업데이트 실패시 http 상태코드 400(BAD_REQUEST)과 에러메세지 반환
		} catch (RuntimeException e) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("error");
		}
	}

	// 사용자의 권한 수정
	@PutMapping("/update-role/{username}")
	public ResponseEntity<?> updateUserRole(@RequestHeader(value = "Authorization") String token,
			@PathVariable("username") String username, @RequestBody UserRoleRequest roleRequest) {

		token = token.substring(7); // "Bearer " 삭제
		UserRole roleFromToken = tokenProvider.getRoleFromToken(token); // 토큰에서 사용자의 role 추출

		// 요청한 사용자가 관리자인지 확인
		if (!roleFromToken.equals(UserRole.TYPE2)) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body("접근 권한이 없습니다.");
		}

		try {
			// 사용자의 권한 업데이트
			userService.updateUserRole(username, roleRequest);
			return ResponseEntity.status(HttpStatus.OK).body("role 업데이트 성공");

			// 권한 업데이트 실패시 http 상태코드 400(BAD_REQUEST)과 에러메세지 반환
		} catch (RuntimeException e) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("error");
		}
	}

	// 삭제
	@DeleteMapping("/delete/{username}")
	public ResponseEntity<?> deleteUser(@RequestHeader(value = "Authorization") String token,
			@PathVariable("username") String username, @RequestBody UserRequest userRequest) {

		token = token.substring(7); // "Bearer " 삭제
		String userFromToken = tokenProvider.getUsernameFromToken(token); // 토큰에서 사용자의 username 추출
		UserRole roleFromToken = tokenProvider.getRoleFromToken(token); // 토큰에서 사용자의 role 추출
		// 토큰의 사용자와 URL의 사용자가 같거나 관리자인지 확인
		if (!username.equals(userFromToken) && !roleFromToken.equals(UserRole.TYPE2)) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body("접근 권한이 없습니다.");
		}

		try {
			// 로그인한 사용자와 수정하려는 회원이 같은지 확인
			if (!userRequest.getUsername().equals(username)) {
				throw new RuntimeException("접근 권한이 없습니다.");
			}
			// 기존 비밀번호와 입력한 비밀번호 비교
			if (!passwordEncoder.matches(userRequest.getPassword(), userService.getUserPassword(username))) {
				throw new RuntimeException("오류발생. 다시 시도해주세요.");
			}

			// userService의 deleteUser 메서드를 사용하여 사용자를 삭제
			userService.deleteUser(username);
			// http 상태코드 204(NO_CONTENT)를 반환
			return ResponseEntity.status(HttpStatus.NO_CONTENT).build();

			// 삭제 실패시 http 상태코드 400(BAD_REQUEST)과 에러메세지 반환
		} catch (RuntimeException e) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("error");
		}
	}

	// 테스트용
	@GetMapping("/health_check")
	public String status() {
		return "user service입니다" + env.getProperty("local.server.port");
	}

	// 테스트 반복문 (랜덤한 가입일과 생일을 가진 회원 200명 생성)
	@PostMapping("/test-insert")
	public void testinsert() {
		Random rand = new Random();
		for (int i = 1; i < 201; i++) {

			String idnum = String.format("%03d", i);
			int year = rand.nextInt(3) + 2021;
			int month = rand.nextInt(12) + 1;
			int day = rand.nextInt(28) + 1;
			Calendar cal = Calendar.getInstance();
			cal.set(year, month - 1, day);
			Date date = cal.getTime();

			UserDTO dto = UserDTO.builder().username("m" + idnum).nickname(idnum + "번째 유저")
					.email("m" + idnum + "@email.com").birth(idnum + "." + idnum).password("12341234").createat(date)
					.updateat(date).build();

			userService.testinsert(dto);
		}
	}

}
