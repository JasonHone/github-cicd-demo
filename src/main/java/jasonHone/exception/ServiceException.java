package jasonHone.exception;



/**
 * Service层异常
 *
 * @author focus
 */
public class ServiceException extends RuntimeException {

    private Integer code;

    private String message;

    private Object errorInfo;

    public ServiceException(Object errorInfo) {
        this.errorInfo = errorInfo;
    }

    public ServiceException(Exception e) {
        this.message = e.getMessage();
        this.code = HttpStatus.ERROR;
    }

    public ServiceException(String message) {
        this.message = message;
        this.code = HttpStatus.ERROR;
    }

    public ServiceException(String message, Integer code) {
        this.message = message;
        this.code = code;
    }

    public ServiceException(String message, Throwable e) {
        super(message, e);
        this.message = message;
    }

    @Override
    public String getMessage() {
        return message;
    }

    public Integer getCode() {
        return code;
    }

    public Object getErrorInfo() {
        return errorInfo;
    }
}
