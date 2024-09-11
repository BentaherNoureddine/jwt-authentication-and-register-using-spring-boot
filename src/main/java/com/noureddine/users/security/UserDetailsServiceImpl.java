package com.noureddine.users.security;



import com.noureddine.users.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor

public class
UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

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


}
