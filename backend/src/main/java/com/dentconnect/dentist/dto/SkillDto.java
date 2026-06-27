package com.dentconnect.dentist.dto;

import com.dentconnect.dentist.entity.Skill;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SkillDto {
    private UUID id;
    private String name;
    private String category;

    public static SkillDto from(Skill skill) {
        return new SkillDto(skill.getId(), skill.getName(), skill.getCategory());
    }
}
