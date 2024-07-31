package com.noureddine.forest.security;


import com.noureddine.forest.user.User;
import com.noureddine.forest.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor

public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    //the @Transactional means when we load the user will be loaded with the roles authorities
    @Transactional
    public UserDetails loadUserByUsername(String userEmail) throws UsernameNotFoundException {
        return userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
    }

    public boolean emailExists(String email) {

        return userRepository.findByEmail(email).isPresent();
    }

    public User validateCredentials(String email, String password) {

         //finding user by email
         User user = userRepository.findByEmail(email)
             .orElseThrow(() -> new UsernameNotFoundException("invalid credentials"));

         if(!passwordEncoder.matches(password,user.getPassword()))
             throw new BadCredentialsException("invalid password");

         return  user;
         }
}
