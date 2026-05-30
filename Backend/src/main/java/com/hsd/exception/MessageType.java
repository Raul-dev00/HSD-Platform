package com.hsd.exception;

import lombok.Getter;

@Getter
public enum MessageType {

    NO_RECORD_EXIST("1001", "Kayıt bulunamadı"),
    ALREADY_EXISTS("1002", "Bu kayıt zaten mevcut"),
    UNAUTHORIZED("1003", "Bu işlem için yetkiniz yok"),
    INVALID_CREDENTIALS("1004", "Email veya şifre hatalı"),
    EMAIL_ALREADY_IN_USE("1005", "Bu email adresi zaten kullanılıyor"),
    PROJECT_APPLICATION_EXISTS("1006", "Bu projeye zaten başvurdunuz"),
    CANNOT_APPLY_OWN_PROJECT("1007", "Kendi projenize başvuramazsınız"),
    INVALID_MESSAGE_TYPE("1008", "Geçersiz mesaj tipi");

    private final String code;
    private final String message;

    MessageType(String code, String message) {
        this.code = code;
        this.message = message;
    }
}
