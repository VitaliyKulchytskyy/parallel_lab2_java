import org.apache.commons.cli.CommandLine;
import java.util.Random;

public class Main {
    public static int[] GenerateRndArray(int length) {
        Random rnd = new Random();
        int[] out = new int[length];

        for(int i = 0; i < out.length; i++)
            out[i] = rnd.nextInt(0, Integer.MAX_VALUE);

        return out;
    }

    public static void main(String[] args) {
        CliParser cli = new CliParser();
        int[] arr = null;

        try {
            cli.parseArgs(args);
            arr = GenerateRndArray(cli.Length);
            int rndIndex = (cli.MinimalIndex >= 0) ?
                    cli.MinimalIndex :
                    new Random().nextInt(0, arr.length - 1);
            arr[rndIndex] = -10;

            if (cli.IsVerbose())
                System.out.println("Defined min index: " + rndIndex);

            int min = new ParallelMin(arr, cli.NumberOfThreads).getMinIndex();
            System.out.println("\nAnswer: " + min);
        } catch (org.apache.commons.cli.ParseException e) {
            System.out.println(e.getMessage());
            cli.printHelp();
            System.exit(1);
        } catch (MinimalIndexException e) {
            System.out.println(e.getMessage());
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } catch (IllegalArgumentException e) {
            System.out.println(arr.length - 1);
        }
    }
}