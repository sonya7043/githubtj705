package kr.co.tj.userservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// 권한설정용
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserRoleRequest{
	
	private String username;
	
	private UserRole role;
	
}
