package kr.co.tj.userservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// 로그인용
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserLoginRequest{
	
	private String username;
	
	private String password;
	
}
