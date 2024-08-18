package com.noureddine.forest.Role;


import com.fasterxml.jackson.annotation.JsonIgnore;
import com.noureddine.forest.user.User;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@EntityListeners(AuditingEntityListener.class)
public class Role {


    @Id
    @GeneratedValue
    private Long id;


    @Column(unique = true)
    private String name;

    @ManyToMany(mappedBy = "roles")
    @JsonIgnore
    private List<User> users;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    //insertable = false means it s not necessary to initialize this attribute
    @Column(insertable = false)
    private LocalDateTime lastModifiedDate;

}
