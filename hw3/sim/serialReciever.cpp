#include <fstream>
#include <string>
#include <regex>
#include <iostream>

#include "serialReciever.h"

SerialReciver::SerialReciver()
{

}

SerialReciver::~SerialReciver()
{
    if(m_outputFile.is_open())
    {
        m_outputFile.close();
    }
    if(m_inputFile.is_open())
    {
        m_inputFile.close();
    }
}

void SerialReciver::setOutputFile(std::string fileName)
{
    m_outputFileName = fileName;
}

void SerialReciver::setInputFile(std::string fileName)
{
    m_inputFileName = fileName;
}

void SerialReciver::mainLoop()
{
    m_outputFile.open(m_outputFileName, std::ofstream::out | std::ofstream::trunc);
    m_inputFile.open(m_inputFileName, std::ifstream::in);
    
    // if no error
    while(!nextState())
    {
        m_clockCycle++;
    }
    m_outputFile << m_clockCycle << " clock cycles"; 
}

bool SerialReciver::nextState()
{
    uint32_t in = 0x0;
    bool reset = false;
    bool error = readInput(in, reset);
    if(!error)
    {
        writeOutput();

        switch(m_currentState)
        {
            case State::RESET:
            {   
                m_bitCounter = 0;
                m_outByte = 0x0;
                m_doneBit = 0x0;

                if(reset == true)
                {
                    m_currentState = State::RESET;
                    break;
                }
                else if(reset == false)
                {
                    m_currentState = State::IDLE;
                    break;
                }
                else
                {
                    m_currentState = State::EXCEPTION;
                    break;
                }
            }
            case State::IDLE:
            {
                if(reset == true)
                {
                    m_currentState = State::IDLE;
                    break;
                }
                else if(reset == false)
                {
                    if(in == 0x0)
                    {
                        m_currentState = State::RECIEVE;
                        break;
                    }
                    else if(in == 0x1)
                    {
                        m_currentState = State::IDLE;
                        break;
                    }
                    else
                    {
                        m_currentState = State::EXCEPTION;
                        break;
                    }
                }
                else
                {
                    m_currentState = State::EXCEPTION;
                    break;
                }
            }
            case State::RECIEVE:
            {
                if(reset == true)
                {
                    m_bitCounter = 0;
		    m_currentState = State::IDLE;
                    break;
                }
                else if(reset == false)
                {
                    if(m_bitCounter<8)
                    {
                        m_outByte = m_outByte<<1;
                        m_outByte |= in;
                        m_bitCounter++;
                        m_currentState = State::RECIEVE;
                        break;
                    }
                    else
                    {
                        // have recived stop bit
                        if((in == 1) && (m_bitCounter == 8))
                        {
                            m_bitCounter = 0;
                            m_doneBit = 1;
                            m_currentState = State::END;
                            break;
                        }
                        else if(in == 0) // have not recieved stop bit
                        {
                            m_currentState = State::RECIEVE;
                            m_bitCounter++;
                            break;
                        }
                        else if((in == 1) && (m_bitCounter > 8))
                        {
                            m_outByte = 0;
                            m_bitCounter = 0;
                            m_currentState = State::IDLE;
                            break;
                        }
                        else
                        {
                            m_currentState = State::EXCEPTION;
                            break;
                        }
                    }
                }
                else
                {
                    m_currentState = State::EXCEPTION;
                    break;
                }
            }
            case State::END:
            {
                if(reset == true)
                {
                    m_currentState = State::IDLE;
                    break;
                }
                else if(reset == false)
                {
                    //m_outByte = 0;
                    m_doneBit = 0;
                    if(in == 0)
                    {
                        m_currentState = State::RECIEVE;
                        break;
                    }
                    else if (in == 1)
                    {
                        m_currentState = State::IDLE;
                        break;
                    }
                    else
                    {
                        m_currentState = State::EXCEPTION;
                        break;
                    }
                }
                else
                {
                    m_currentState = State::EXCEPTION;
                    break;
                }
            } 
            case State::EXCEPTION:
            {
                // we should never reach this state
                // if we did, something truely went very wrong
                std::cerr << "exception caught"<<std::endl;

                if(reset == true)
                {
                    m_currentState = State::IDLE;
                    break;
                }
                else
                {
                    m_currentState =  State::EXCEPTION;
                    break;
                }
            }
        }
    }
    return error; 
}

bool SerialReciver::readInput(uint32_t& in, bool& reset)
{
    bool error = false; 
    std::regex pattern("([01]),\\s([01])");
    std::smatch match;
    std::string line;

    if(std::getline(m_inputFile, line))
    {
        if(line.empty())
        {
            error = true;
        }
        else
        {
            //strip anything from "//" to end‑of‑line
            auto pos = line.find("//");
            if (pos != std::string::npos)
            {
                line.erase(pos);
            }

            if(std::regex_search(line, match, pattern))
            {
                std::string str1(match[1]);
                std::string str2(match[2]);
                in = static_cast<uint32_t>(std::stoi(str1));
                reset = static_cast<bool>(std::stoi(str2));
            }
            else
            {
                error = true;
            }
        }
    }
    else
    {
        error = true;
    }
    return error;
}

void SerialReciver::writeOutput()
{
    m_outputFile << (uint32_t)m_outByte << ", "<< m_doneBit<<std::endl;
}
