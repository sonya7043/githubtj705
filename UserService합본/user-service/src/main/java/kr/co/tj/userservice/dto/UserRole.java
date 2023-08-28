package kr.co.tj.userservice.dto;

// role을 enum으로 설정하여 추후 다른 타입의 권한을 편하게 추가할 수 있게 함
public enum UserRole {
 TYPE1("user"), TYPE2("admin"), TYPE3("blocked");

 private String roleName;

 UserRole(String roleName) {
     this.roleName = roleName;
 }

 public String getRoleName() {
     return roleName;
 }
}
