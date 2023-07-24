package kr.co.tj.userservice.jpa;

import java.util.Date;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import kr.co.tj.userservice.dto.UserEntity;

public interface UserRepository extends JpaRepository<UserEntity, String>{

	UserEntity findByUsername(String username);

	Page<UserEntity> findByCreateatBetween(Date startDate, Date endDate, Pageable pageable);

	UserEntity findByEmail(String email);

}
