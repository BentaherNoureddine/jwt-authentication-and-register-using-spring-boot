package com.noureddine.users.exeption;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;


public class EmailAlreadyExistException extends ResponseStatusException {

public EmailAlreadyExistException() {

    super(HttpStatus.CONFLICT,"Email already exist");
}
}
