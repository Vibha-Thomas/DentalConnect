package com.dentconnect.common.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

@Converter
public class StringListConverter implements AttributeConverter<List<String>, String> {
    @Override
    public String convertToDatabaseColumn(List<String> list) {
        if (list == null || list.isEmpty()) return null;
        return String.join(",", list);
    }
    @Override
    public List<String> convertToEntityAttribute(String s) {
        if (s == null || s.isBlank()) return new ArrayList<>();
        return new ArrayList<>(Arrays.asList(s.split(",")));
    }
}
