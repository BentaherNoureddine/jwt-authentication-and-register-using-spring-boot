package com.noureddine.forest.security;


import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;


//this class is a service that generate , decode , extract ,validate ... the jwt  token

@Service
@RequiredArgsConstructor
public class JwtService {

    @Value("${application.security.jwt.expiration}")
    private Long  jwtExpiration;
    @Value("${application.security.jwt.secret-key}")
    private String secretKey;





    //method that generate a token
    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(),userDetails);

    }

    //this method extract the username within we set the subject of the token
    public String extractUsername(String token) {
        return extractClaim(token, Claims ::getSubject);
    }

    //this is a generated method
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);


    }

    private Claims extractAllClaims(String token) {
        return Jwts
                .parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody()
                ;
    }

    //this method in case we only need to include userDetails, or we need to include extra information within the jwt token
    private  String generateToken(Map<String, Object> claims, UserDetails userDetails) {

        return buildToken(claims, userDetails,jwtExpiration);
    }

    private String buildToken(
            //the extra infos that we need
            Map<String, Object> extraClaims,
            UserDetails userDetails,
            Long jwtExpiration
    ) {
        //include the authorities to the token
        var authorities = userDetails.getAuthorities()
                .stream()
                //make it a string since we only need the names of the authorities
                .map(GrantedAuthority::getAuthority)
                .toList();

        return Jwts
                .builder()
                .setClaims(extraClaims)
                //the userId of our token
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                //how long the token should expire
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .claim("authorities" ,authorities)
                .signWith(getSignInKey())
                //generate the token
                .compact()
                ;
    }

    public Boolean isTokenValid(String token , UserDetails userDetails) {

        final  String username = extractUsername(token);

        return (username.equals(userDetails.getUsername()) ) && !isTokenExpired(token);
    }

    private boolean isTokenExpired(String token) {
        return  extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {

        return extractClaim(token,Claims::getExpiration);
    }


    //decode the signing key
    private Key getSignInKey() {

        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }



}
