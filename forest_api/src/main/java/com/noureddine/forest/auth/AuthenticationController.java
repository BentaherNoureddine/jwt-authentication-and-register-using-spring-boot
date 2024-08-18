package com.noureddine.forest.auth;


import com.noureddine.forest.exeption.EmailAlreadyExistException;
import io.swagger.v3.oas.annotations.tags.Tag;
//import jakarta.mail.MessagingException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("auth")
@RequiredArgsConstructor
@Tag(name ="authentication")
public class AuthenticationController {

    private final AuthenticationService authenticationService;


    //REGISTRATION API
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody @Valid final RegistrationRequest request){

        try {
            authenticationService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body("User registered successfully");
        }catch(EmailAlreadyExistException e){
           return ResponseEntity.status(HttpStatus.CONFLICT).body("Email already exist");
        }
        catch (Exception e){
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("error while registration user");
        }
    }


    //AUTHENTICATION API
    @PostMapping("/authenticate")
    public  ResponseEntity<AuthenticationResponse> authenticate(
            @RequestBody @Valid final AuthenticationRequest request
    ){
    return ResponseEntity.ok(authenticationService.authenticate(request));



    }

}
