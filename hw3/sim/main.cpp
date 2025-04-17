#include <iostream>
#include "serialReciever.h"

int main(int argc, char *argv[])
{
    if(argc == 1)
    {
        // defaults
        SerialReciver myReciever;
        myReciever.mainLoop();
    }
    else if(argc == 2)
    {
        std::string arg1 = argv[1];
        if((arg1 == "--help")||(arg1 == "-h"))
        {
            std::cout<<"--help, -h prints help"<<std::endl;
            std::cout<<"--version prints version"<<std::endl;
            std::cout<<"--input, -i \"filename\" sets the input filename"<<std::endl;
            std::cout<<"--output, -o \"filename\" sets the output filename"<<std::endl;
        }
        else if((arg1 == "--version"))
        {
            std::cout<<"Serial reciever simulator version 1.0"<<std::endl;
            std::cout<<"Copyright (C) Matthew Hardenburgh, All rights reserved"<<std::endl;
        }
        else
        {
            std::cout<<"Unrecognized input"<<std::endl;
        }
    }
    else if(argc == 3)
    {
        std::string arg1 = argv[1];
        std::string filename = argv[2];
        if((arg1 == "--input")||(arg1 == "-i"))
        {

        }
        else if((arg1 == "--output")||(arg1 == "-o"))
        {

        }
        else
        {
            std::cout<<"Unrecognized input"<<std::endl;
        }
    }
    else if(argc == 5)
    {
        std::string arg1 = argv[1];
        std::string arg2 = argv[3];
        std::string inputFilename = argv[2];
        std::string outputFilename = argv[4];
    }
    
    
    return 0;
}