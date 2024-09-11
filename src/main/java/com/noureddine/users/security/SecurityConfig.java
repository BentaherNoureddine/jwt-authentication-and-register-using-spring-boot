package com.noureddine.users.security;


import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;


//spring will know we have beans to configure
@Configuration
@EnableWebSecurity
//create a constructor with all final fields
@RequiredArgsConstructor
@EnableMethodSecurity(securedEnabled = true)
public class SecurityConfig {



    private final JwtFilter jwtAuthFilter;

    private final AuthenticationProvider authenticationProvider;


    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                .cors(Customizer.withDefaults())
                //we have to disable the csrf
                .csrf(AbstractHttpConfigurer :: disable)
                //authorized endpoints
                .authorizeHttpRequests(req ->
                        req.requestMatchers(
                                "/auth/**"

                        ).permitAll()
                                //the request at the request matchers don t need to be authenticated but those must be
                                .anyRequest()
                                .authenticated()
                )
                //the type of the session management
                .sessionManagement(session ->
                        //when we use STATELESS means we will treat every request like we don't know anything about it
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authenticationProvider(authenticationProvider)
               /* adding the filter that we will need and it s a custom filter (jwt filter) and we should execute jwtFilter before
        UsernamePasswordAuthenticationFilter to check if the request contains a token,exists ...*/
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);


                return http.build();



    }
}
