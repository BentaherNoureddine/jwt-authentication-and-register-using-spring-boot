package com.noureddine.forest.auth;



import com.noureddine.forest.Role.RoleRepository;
//import com.noureddine.forest.email.EmailService;
// com.noureddine.forest.email.EmailTemplateName;
import com.noureddine.forest.exeption.EmailAlreadyExistException;
import com.noureddine.forest.security.UserDetailsServiceImpl;

import com.noureddine.forest.user.TokenRepository;
import com.noureddine.forest.user.User;
import com.noureddine.forest.user.UserRepository;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private static final Logger log = LoggerFactory.getLogger(AuthenticationService.class);
    private final UserRepository userRepository;

    private final UserDetailsServiceImpl userService;

    private final  RoleRepository roleRepository;

    private final PasswordEncoder passwordEncoder;

    private final TokenRepository tokenRepository;

    //private final  EmailService emailService;

   // @Value("${application.mailing.frontend.activation-url}")
    private String activationUrl;





    public void register(RegistrationRequest request) throws MessagingException {

        var userRole = roleRepository.findByName("USER")
                // todo better exception handling
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
                    .enabled(true)
                    .roles(List.of(userRole))
                    .build();

        userRepository.save(user);


        //sendValidationEmail(user);


    }
/*

    private void sendValidationEmail(User user) throws MessagingException {

        var newToken = generateAndSaveActivationToken(user);

        emailService.sendEmail(
                user.getEmail(),
                user.fullName(),
                EmailTemplateName.ACTIVATE_ACCOUNT,
                activationUrl,
                newToken,
                "Account activation"
        );
    }



    private String generateAndSaveActivationToken(User user) {

        //generate a token
        String generatedToken = generateActivationCode(6);

        var token = Token.builder()
                .token(generatedToken)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusMinutes(30))
                .user(user)
                .build();

        tokenRepository.save(token);

        return generatedToken;



    }

    private String generateActivationCode(int length) {

        String characters = "0123456789";
        StringBuilder codeBuilder = new StringBuilder();
        SecureRandom secureRandom = new SecureRandom();
        for (int i = 0; i < length; i++) {

            int randomIndex = secureRandom.nextInt(characters.length());
            codeBuilder.append(characters.charAt(randomIndex));
        }

        return codeBuilder.toString();
    }
     */
}
