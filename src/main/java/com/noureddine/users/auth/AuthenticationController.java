package com.noureddine.users.auth;


import com.noureddine.users.exeption.EmailAlreadyExistException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("auth")
@CrossOrigin(origins = {"http://localhost:9654" ,"http://192.168.0.17"})
@RequiredArgsConstructor
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
    @CrossOrigin(origins ="http://localhost:9654" )
    @PostMapping("/authenticate")
    public  ResponseEntity<AuthenticationResponse> authenticate(
            @RequestBody @Valid final AuthenticationRequest request
    ){
    return ResponseEntity.ok(authenticationService.authenticate(request));



    }

}
