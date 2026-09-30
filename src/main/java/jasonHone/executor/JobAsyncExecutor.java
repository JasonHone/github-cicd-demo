package jasonHone.executor;

import java.util.Map;

import lombok.Data;
import lombok.Getter;

/**
 * A asynchronous job executor interface
 * @author xiaoyang.zhang
 */
public interface JobAsyncExecutor {

    /**
     * Submit a job to executor
     *
     * @param batchId a batch has a lot of lines
     * @param lineId an ID that identifies the smallest execution unit
     * @param job a function that submitted to run, it handles a line
     * @throws SubmitException an error occur when submit a job to executor
     */
    void execute(String batchId, String lineId, JobRunner job) throws SubmitException;

    /**
     * Query the batch result at the current time.
     * It's a global result, not only on this executor/machine
     *
     * @param batchId
     * @return a global result of this batch submitted by all executors in all machines
     * @throws QueryResultException an error occur when query from executor
     */
    BatchResult queryBatchSnapshotResult(String batchId) throws QueryResultException;

    /**
     * Query the batch failed lines and their error messages at the current time.
     * It's a global result, not only on this executor/machine
     *
     * @param batchId
     * @return A map that key is lineId, value is it's error message
     * @throws QueryResultException an error occur when query from executor
     */
    Map<String, String> queryFailedLinesInBatch(String batchId) throws QueryResultException;

    /**
     * Release local resources on this executor/machine when this batch in this executor finished
     *
     * @param batchId
     */
    void releaseLocalResources(String batchId);

    /**
     * Release global resources on all executors in all machines when this batch all finished in different executors/machines
     *
     * @param batchId
     * @throws ReleaseResException
     */
    void releaseGlobalResources(String batchId) throws ReleaseResException;

    /**
     * Whether this batch in this executor is finished or not.
     * This mathod tells that batch in local executor is finished or not,
     * cannot tells the same batch in other executor/machine is finished or not
     *
     * @param batchId
     * @return
     */
    boolean isLocalFinished(String batchId);

    @FunctionalInterface
    public static interface JobRunner {
        LineResult run();
    }

    @Getter
    public static class LineResult {
        private boolean success;
        private String errorMsg;

        private LineResult() {};

        public static LineResult failed(String errorMsg) {
            LineResult result = new LineResult();
            result.success = false;
            result.errorMsg = errorMsg;
            return result;
        }

        public static LineResult success() {
            LineResult result = new LineResult();
            result.success = true;
            return result;
        }
    }

    @Data
    public static class BatchResult {
        /**
         * Already submitted to asyncExecutor at this time, maybe they were executed, maybe not.
         * This is a global value, not just this executor
         */
        private long submittedCount;

        /**
         * Already execute successfully at this time.
         * This is a global value, not just this executor
         */
        private long successCount;

        /**
         * The execution has already failed at this time.
         * This is a global value, not just this executor
         */
        private long failedCount;
    }

    public static class SubmitException extends Exception {
        private static final long serialVersionUID = 3702468162494089934L;

        public SubmitException(String msg, Throwable cause) {
            super(msg, cause);
        }
    }

    public static class QueryResultException extends Exception {
        private static final long serialVersionUID = -7337673470184909978L;

        public QueryResultException(String msg, Throwable cause) {
            super(msg, cause);
        }
    }

    public static class ReleaseResException extends Exception {
        private static final long serialVersionUID = -4952714938347583115L;

        public ReleaseResException(String msg, Throwable cause) {
            super(msg, cause);
        }
    }
}
