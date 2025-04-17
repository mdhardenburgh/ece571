#include <fstream>
#include <string>
#include <regex>
#include <iostream>

#include "serialReciever.h"

SerialReciver::SerialReciver()
{
    m_outputFile.open(m_outputFileName, std::ofstream::out | std::ofstream::app);
    m_inputFile.open(m_inputFileName, std::ifstream::in);
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

void SerialReciver::mainLoop()
{
    // if no error
    while(!nextState())
    {
        m_clockCycle++;
    }
}

bool SerialReciver::nextState()
{
    bool error = false; 
    uint32_t in = 0x0;
    bool reset = false;
    
    switch(m_currentState)
    {
        case State::RESET:
        {   
            m_bitCounter = 0;
            m_outByte = 0x0;
            error = readInput(in, reset);

            if(reset == true)
            {
                m_currentState = State::RESET;
                break;
            }
            else
            {
                m_currentState = State::IDLE;
                break;
            }
        }
        case State::IDLE:
        {
            m_bitCounter = 0;
            m_outByte = 0x0;
            error = readInput(in, reset);

            if(reset == true)
            {
                m_currentState = State::RESET;
                break;
            }
            else
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
            }
        }
        case State::RECIEVE:
        {
            error = readInput(in, reset);

            if(reset == true)
            {
                m_currentState = State::RESET;
                break;
            }
            else
            {
                if(m_bitCounter<7)
                {
                    m_outByte = m_outByte<<1;
                    m_outByte |= in;
                    m_bitCounter++;
                    m_currentState = State::RECIEVE;
                    break;
                }
                else if(m_bitCounter == 7)
                {
                    m_outByte = m_outByte<<1;
                    m_outByte |= in;
                    m_bitCounter++;
                    m_currentState = State::END;
                    break;
                }
            }
        }
        case State::END:
        {
            writeOutput();
            m_outByte = 0;
            writeDone();
            m_currentState = State::IDLE;
        } 
        default:
        {
            // we should never reach this state
            // if we did, something went very wrong
            error = true;
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
    m_outputFile << m_outByte << ", ";
}

void SerialReciver::writeDone()
{
    m_outputFile << 1 << std::endl;
}