package kr.co.tj.userservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// 비번설정용
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserPassRequest{
	
	private String username;
	
	private String password;
	private String password2;
	private String orgPassword;
	
	private UserRole role;
	
}
