package com.noureddine.users.repositories;

import com.noureddine.users.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;



public interface UserRepository  extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);
}
