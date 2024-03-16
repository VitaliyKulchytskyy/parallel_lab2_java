import org.apache.commons.cli.*;

public class CliParser {
    private final Options options = new Options();
    private final CommandLineParser parser = new GnuParser();
    private final HelpFormatter formatter = new HelpFormatter();
    private boolean IsVerbose;
    public int NumberOfThreads = 1;
    public int MinimalIndex = -1;
    public int Length = 1;

    public CliParser() {
        options.addOption(new Option("h", "help", false, "Display this help text"));
        options.addOption(new Option("v", "verbose", false, "Print verbose information"));
        options.addOption(new Option("n", "thread", true, "Set the number of threads"));
        options.addOption(new Option("m", "min-index", true, "Manual set the index of a minimal value"));
        options.addOption(new Option("l", "length", true, "Set the length of the array"));
    }

    public void parseArgs(String[] args) throws ParseException, MinimalIndexException {
        CommandLine cmd = this.parser.parse(this.options, args);

        if (cmd.hasOption("h")) {
            printHelp();
            System.exit(0);
        }

        NumberOfThreads = cmd.hasOption("n") ? Integer.parseInt(cmd.getOptionValue("n")) : 1;
        MinimalIndex = cmd.hasOption("m") ? Integer.parseInt(cmd.getOptionValue("m")) : -1;
        Length = cmd.hasOption("l") ? Integer.parseInt(cmd.getOptionValue("l")) : 1;
        IsVerbose = cmd.hasOption("v");

        if (MinimalIndex >= Length)
            throw new MinimalIndexException("Error while parsing command-line arguments: (Array length)=" + Length + " <= (Manual min. index)=" + MinimalIndex);

        if (IsVerbose()) {
            System.out.println("Threads: " + NumberOfThreads);
            System.out.println("Arr length: " + Length);
            if (MinimalIndex >= 0)
                System.out.println("Manual min: " + MinimalIndex);
            System.out.println();
        }
    }

    public boolean IsVerbose() {
        return IsVerbose;
    }

    public void printHelp() {
        this.formatter.printHelp("Lab2", this.options);
    }
}
