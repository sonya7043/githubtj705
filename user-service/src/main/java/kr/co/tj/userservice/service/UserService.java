package kr.co.tj.userservice.service;

import java.util.List;

import kr.co.tj.userservice.dto.UserDTO;
import kr.co.tj.userservice.dto.UserPassRequest;
import kr.co.tj.userservice.dto.UserRequest;

public interface UserService {
	
	UserDTO login(UserDTO userDTO);
	
	UserDTO createUser(UserDTO userDTO);
	
	UserRequest updateUser(String username, UserRequest userRequest);
	
	UserPassRequest updatePass(String username, UserPassRequest userPass);
	
	String getUserPassword(String username);
	
	void deleteUser(String username);
	
	List<UserDTO> getUsers();
	
	UserDTO getUser(String username);
	
	UserDTO getDate(UserDTO userDTO);
	
	void testinsert(UserDTO dto);

}
