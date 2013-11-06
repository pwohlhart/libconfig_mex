#include "mex.h"

#include <string>
#include <stdio.h>
#include <libconfig.h++>
#include "LibConfigMexWrapper.h"

using namespace libconfig;

enum CommandType {CMD_INVALID, CMD_OPEN, CMD_CLOSE, CMD_GET, CMD_EXISTS, CMD_ISGROUP, CMD_GETLENGTH, CMD_GETSUBSETTINGNAMEBYIDX };


bool getStringArgument(const mxArray *prhs[], int idx, std::string &argStr)
{
    if (!mxIsClass(prhs[idx],"char"))
        return false;

    char *argPChar;
    int inputLen;
    int status;
    inputLen = mxGetN(prhs[idx])*sizeof(mxChar)+1;
    argPChar = (char*)mxMalloc(inputLen);
    status = mxGetString(prhs[idx], argPChar, inputLen);
    argStr = argPChar;
    mxFree(argPChar);
    return true;
}

CommandType getCommand(const mxArray *prhs[]) 
{
    /*
    if (!mxIsClass(prhs[0],"char"))
        return CMD_INVALID;
    
    // read command
    char *commandPChar;
    int inputLen;
    int status;
    inputLen = mxGetN(prhs[0])*sizeof(mxChar)+1;
    commandPChar = (char*)mxMalloc(inputLen);
    status = mxGetString(prhs[0], commandPChar, inputLen);   
    std::string commandStr(commandPChar);
    */
    
    std::string commandStr;
    if (!getStringArgument(prhs,0,commandStr))
        return CMD_INVALID;
            
    if (commandStr.compare("open") == 0)
        return CMD_OPEN;
    if (commandStr.compare("close") == 0)
        return CMD_CLOSE;
    if (commandStr.compare("get") == 0)
        return CMD_GET;
    if (commandStr.compare("exists") == 0)
        return CMD_EXISTS;
    if (commandStr.compare("isGroup") == 0)
        return CMD_ISGROUP;
    if (commandStr.compare("getLength") == 0)
        return CMD_GETLENGTH;
    if (commandStr.compare("getSubSettingNameByIdx") == 0)
        return CMD_GETSUBSETTINGNAMEBYIDX;

    return CMD_INVALID;
}


/* main */
void mexFunction(int nlhs, mxArray *plhs[], /* Output variables */
                int nrhs, const mxArray *prhs[]) /* Input variables */
{
    if (nrhs < 2)
    {
        mexErrMsgTxt("Need two input arguments!\n"); /* Do something interesting */
        return;
    }
    
    CommandType command = getCommand(prhs);
    if (command == CMD_INVALID)
    {
        if (mxIsClass(prhs[0],"char"))
            mexErrMsgTxt("Not a valid command");
        else
            mexErrMsgTxt("The first argument must be a command string");
        return;
    }
    
    if (command == CMD_OPEN)
    {
        // open the config file
        std::string filename;
        if (!getStringArgument(prhs,1,filename))
        {
            mexErrMsgTxt("Second argument must be a string (the filename of the config file)");
            return;
        }
        
        mexPrintf("open '%s' ... ",filename.c_str());

    	LibConfigMexWrapper *wrapper = new LibConfigMexWrapper();

    	if (wrapper->readFile(filename))
    	{
    		// return wrapper
			plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
			double* ptrWrapper = mxGetPr(plhs[0]);
			ptrWrapper[0] = (long) wrapper;
    	}
    	else
    		delete wrapper;

	} else if (command == CMD_CLOSE) {

		LibConfigMexWrapper *wrapper = LibConfigMexWrapper::retrieveAndCheckPtr(nrhs,prhs);
		if (wrapper)
		{
			wrapper->close();
			delete wrapper;
		}

	} else if (command == CMD_GET) {
		LibConfigMexWrapper *wrapper = LibConfigMexWrapper::retrieveAndCheckPtr(nrhs,prhs);
		if (wrapper)
			wrapper->lookup(nlhs,plhs,nrhs,prhs);
	} else if (command == CMD_EXISTS) {
		LibConfigMexWrapper *wrapper = LibConfigMexWrapper::retrieveAndCheckPtr(nrhs,prhs);
		if (wrapper)
			wrapper->exists(nlhs,plhs,nrhs,prhs);
	} else if (command == CMD_ISGROUP) {
		LibConfigMexWrapper *wrapper = LibConfigMexWrapper::retrieveAndCheckPtr(nrhs,prhs);
		if (wrapper)
			wrapper->isGroup(nlhs,plhs,nrhs,prhs);
	} else if (command == CMD_GETLENGTH) {
		LibConfigMexWrapper *wrapper = LibConfigMexWrapper::retrieveAndCheckPtr(nrhs,prhs);
		if (wrapper)
			wrapper->getLength(nlhs,plhs,nrhs,prhs);
	} else if (command == CMD_GETSUBSETTINGNAMEBYIDX) {
		LibConfigMexWrapper *wrapper = LibConfigMexWrapper::retrieveAndCheckPtr(nrhs,prhs);
		if (wrapper)
			wrapper->getSubSettingNameByIdx(nlhs,plhs,nrhs,prhs);
    }
    
    return;
}

