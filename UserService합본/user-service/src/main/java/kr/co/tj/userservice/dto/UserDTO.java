package kr.co.tj.userservice.dto;

import java.io.Serializable;
import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDTO implements Serializable {

	private static final long serialVersionUID = 1L;

	private String id;

	private String username; // 로그인 아이디

	private String nickname; // 닉네임

	private String password;

	private String email;

	private String birth; // 생년월일

	private Date createat; // 가입일

	private Date updateat; // 갱신일

	private String token;

	private UserRole role; // 권한

	public UserDTO toUserDTO(UserEntity userEntity) {
		this.username = userEntity.getUsername();
		this.nickname = userEntity.getNickname();
		this.email = userEntity.getEmail();
		this.birth = userEntity.getBirth();
		this.role = userEntity.getRole();
		this.createat = userEntity.getCreateat();
		this.updateat = userEntity.getUpdateat();
		this.token = userEntity.getToken();
		return this;
	}

	public UserEntity toUserEntity() {
		return UserEntity.builder()
				.username(username)
				.password(password)
				.nickname(nickname)
				.email(email)
				.birth(birth)
				.role(UserRole.TYPE1)
				.createat(createat)
				.updateat(updateat)
				.build();
	}

	public static UserDTO toUserDTO(UserRequest ureq) {
		return UserDTO.builder()
				.username(ureq.getUsername())
				.password(ureq.getPassword())
				.nickname(ureq.getNickname())
				.email(ureq.getEmail())
				.birth(ureq.getBirth())
				.role(ureq.getRole())
				.build();
	}

	public UserResponse toUserResponse() {
		return UserResponse.builder()
				.username(username)
				.nickname(nickname)
				.email(email)
				.birth(birth)
				.createat(createat)
				.updateat(updateat)
				.token(token)
				.role(role)
				.build();
	}

	public static UserDTO toUserDTO(UserLoginRequest userLoginRequest) {
		return UserDTO.builder()
				.username(userLoginRequest.getUsername())
				.password(userLoginRequest.getPassword())
				.build();
	}

}
