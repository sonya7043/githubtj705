package kr.co.tj.userservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserRequest{
	
	private String username;
	
	private String password;
	private String password2;
	private String orgPassword;
	
	private String nickname;
	
	private String email;
	
	private String birth;
	
	private UserRole role;
	
}
