package kr.co.tj.userservice.dto;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

import org.hibernate.annotations.GenericGenerator;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@Table(name = "users")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserEntity implements Serializable {

	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(generator = "id-uuid")
	@GenericGenerator(strategy = "uuid", name = "id-uuid")
	private String id;

	@Column(nullable = false, unique = true)
	private String username;

	@Column(nullable = false)
	private String nickname;

	@Column(nullable = false)
	private String password;

	@Column(nullable = false)
	private String email;

	private String birth;

	private Date createat;

	private Date updateat;

	private String token;

	@Column(nullable = false)
	@Enumerated(EnumType.STRING)
	private UserRole role;

}
