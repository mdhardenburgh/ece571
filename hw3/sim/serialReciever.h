#include <cstdint>
#include <string>
#include <fstream>

enum class State:uint32_t{IDLE, RECIEVE, END, RESET};

class SerialReciver
{
    public:
        SerialReciver();
        SerialReciver(std::string outputFile, std::string m_inputFile);
        ~SerialReciver();
        void mainLoop();
        void setOutputFile(std::string fileName);
        void setInputFile(std::string fileName);
    
    private:
        bool nextState();
        void writeToFile(std::string message);
        bool readInput(uint32_t& in, bool& reset); // return true if error
        void writeOutput();
        void writeDone();
        
        std::ofstream m_outputFile;
        std::ifstream m_inputFile;
        uint32_t m_outByte = 0x0;
        uint64_t m_clockCycle = 0;
        State m_currentState = State::IDLE;
        uint32_t m_bitCounter = 0;
        // each line is a clock cycle
        std::string m_outputFileName = "serialReceiverOutput.txt";
        // each line is a clock cycle
        // first char is serial in, second is synchronous reset
        std::string m_inputFileName = "serialRecieverInput.txt";
};