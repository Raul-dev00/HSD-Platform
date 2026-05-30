package com.hsd.exception;

public class BaseException extends RuntimeException {

    public BaseException() {
        super();
    }

    public BaseException(ErrorMessage errorMessage) {
        super(errorMessage.prepareErrorMessage());
    }

    public BaseException(String message) {
        super(message);
    }
}
