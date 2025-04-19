#include <iostream>
#include <string>
#include "serialReciever.h"

int main(int argc, char *argv[])
{
    SerialReciver myReciever;
    bool badInput = false;

    if(argc == 1)
    {
        // defaults
        myReciever.mainLoop();
    }
    else if(argc == 2)
    {
        std::string arg1(argv[1]);
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
        std::string arg1(argv[1]);
        std::string filename(argv[2]);
        if((arg1 == "--input")||(arg1 == "-i"))
        {
            myReciever.setInputFile(filename);
        }
        else if((arg1 == "--output")||(arg1 == "-o"))
        {
            myReciever.setOutputFile(filename);
        }
        else
        {
            std::cout<<"Unrecognized input"<<std::endl;
            badInput = true;
        }

        if(!badInput)
        {
            myReciever.mainLoop();
        }
    }
    else if(argc == 5)
    {
        std::string arg1(argv[1]);
        std::string arg2(argv[3]);
        std::string filename1(argv[2]);
        std::string filename2(argv[4]);

        if((arg1 == "--input")||(arg1 == "-i"))
        {
            myReciever.setInputFile(filename1);
        }
        if((arg1 == "--output")||(arg1 == "-o"))
        {
            myReciever.setOutputFile(filename1);
        }
        if((arg2 == "--input")||(arg2 == "-i"))
        {
            myReciever.setInputFile(filename2);
        }
        if((arg2 == "--output")||(arg2 == "-o"))
        {
            myReciever.setOutputFile(filename2);
        }
        else
        {
            std::cout<<"Unrecognized input"<<std::endl;
            badInput = true;
        }

        if(!badInput)
        {
            myReciever.mainLoop();
        }
    }
    
    
    return 0;
}