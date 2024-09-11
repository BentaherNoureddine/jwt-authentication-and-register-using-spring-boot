package com.noureddine.users.auth;



import com.noureddine.users.repositories.RoleRepository;
import com.noureddine.users.exeption.EmailAlreadyExistException;
import com.noureddine.users.security.JwtService;
import com.noureddine.users.security.UserDetailsServiceImpl;
import com.noureddine.users.models.User;
import com.noureddine.users.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private static final Logger log = LoggerFactory.getLogger(AuthenticationService.class);
    private final UserRepository userRepository;

    private final UserDetailsServiceImpl userService;

    private final  RoleRepository roleRepository;

    private final PasswordEncoder passwordEncoder;


    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;





    //register method that will be called at the authentication controller
    public void register(RegistrationRequest request) {

        var userRole = roleRepository.findByName("USER")
                .orElseThrow(() -> new IllegalArgumentException("Role USER was not initialized"));



        //If an account with the given email already exists, throws an EmailAlreadyExist exception
        if(userService.emailExists(request.getEmail())){
             log.error("Email already exists");
             throw new EmailAlreadyExistException();
        }
        var user = User.builder()
                    .firstname(request.getFirstname())
                    .lastname(request.getLastname())
                    .email(request.getEmail())
                    .password(passwordEncoder.encode(request.getPassword()))
                    .accountLocked(false)
                    .score(0)
                    .roles(List.of(userRole))
                    .build();

        userRepository.save(user);


    }


    //authentication method that will be called at the authentication controller
    public AuthenticationResponse authenticate(AuthenticationRequest request) {

        var auth = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        var claims = new HashMap<String, Object>();
        var user = ((User) auth.getPrincipal());
        claims.put("fullName", user.fullName());
        var jwtToken = jwtService.generateToken(claims, user);

        //return a login token
        return AuthenticationResponse.builder().token(jwtToken).build();
    }


}
