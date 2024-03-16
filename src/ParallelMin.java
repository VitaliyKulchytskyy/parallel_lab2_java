import java.util.concurrent.CountDownLatch;

public class ParallelMin {
    private final int[] Array;
    private final int ThreadNum;
    private final CountDownLatch Count;
    private int MinIndex = 0;

    public class FindMin implements Runnable {
        private final int Start;
        private final int End;

        public FindMin(int start, int end) {
            Start = start;
            End = end;
        }

        @Override
        public void run() {
            int min = getMinIndex();
            setMinIndex(min);
            Count.countDown();
        }

        private int getMinIndex() {
            int output = Start;

            for (int i = Start; i <= End; i++)
                if (Array[i] < Array[output])
                    output = i;

            return output;
        }
    }

    public ParallelMin(int[] array, int threadNum) {
        Array = array;
        ThreadNum = threadNum;
        Count = new CountDownLatch(threadNum);
    }

    public int getMinIndex() throws InterruptedException {
        int step = Array.length / ThreadNum;

        if (ThreadNum - 1 > 0) {
            for (int i = 1; i < ThreadNum; i++) {
                new Thread(new FindMin(step * (i - 1), step * i - 1)).start();
            }
        }
        new Thread(new FindMin(step * (ThreadNum - 1),  Array.length - 1)).start();
        Count.await();

        return MinIndex;
    }

    synchronized private void setMinIndex(int min) {
        if (Array[min] < Array[MinIndex])
            MinIndex = min;
    }
}
