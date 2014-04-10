/*
 * LibConfigMexWrapper.cpp
 *
 *  Created on: 20.12.2010
 *      Author: pwohlhart
 */

#include "LibConfigMexWrapper.h"

#include <math.h>

//#include "boost/filesystem.hpp"
//namespace bfs = boost::filesystem;


LibConfigMexWrapper::LibConfigMexWrapper() {
}

LibConfigMexWrapper::~LibConfigMexWrapper() {
}


LibConfigMexWrapper *LibConfigMexWrapper::retrieveAndCheckPtr(int inputSize, const mxArray *input[])
{
	LibConfigMexWrapper *wrapperObjPtr = NULL;

	if(inputSize < 1 || !mxIsNumeric(input[1]))
		mexErrMsgTxt("Error missing argument: Pointer to HOG object!\n" );

    // retrieve pointer from the MX form
    double* mxDataPtr = mxGetPr(input[1]);

    // check that I actually received something
    if( mxDataPtr == NULL )
        mexErrMsgTxt("Error no valid HOG object pointer!\n");

    // long is good for pointers :-)
    long tmpPtr = (long) mxDataPtr[0];
    // convert it
    wrapperObjPtr = (LibConfigMexWrapper*) tmpPtr;

    // check that I actually received something
    if( wrapperObjPtr == NULL )
        mexErrMsgTxt("Error no valid object pointer!\n");

    return wrapperObjPtr;
}

bool LibConfigMexWrapper::readFile(std::string filename)
{
	try {
		//bfs::path filepath(filename);
		//_configFile.setIncludeDir(filepath.parent_path().native().c_str());
		//mexPrintf("root path ",_configFile.getIncludeDir());

		size_t pos = filename.find_last_of("/\\");
		//mexPrintf("* %d *",pos);
		if (pos > 0)
		{
			std::string filepath = filename.substr(0,pos+1);
			_configFile.setIncludeDir(filepath.c_str());
			//mexPrintf("root path %s\n",_configFile.getIncludeDir());
		}

		_configFile.readFile(filename.c_str());
		mexPrintf("ok\n");
	}
	catch (FileIOException &e)
	{
		mexPrintf("failed\n");
		mexPrintf("Problem reading config file '%s' (%s)\n",filename.c_str(),e.what());
		return false;
	}
	catch (ParseException &e)
	{
		mexPrintf("failed\n");
		mexPrintf("Problem reading config file '%s' (%s)\n",filename.c_str(),e.what());
		mexPrintf("  error: %s\n",e.getError());
		mexPrintf("  line: %d\n",e.getLine());
		return false;
	}
	catch (...)
	{
		mexPrintf("failed\n");
		mexPrintf("Problem reading config file\n");
		return false;
	}

	return true;
}

void LibConfigMexWrapper::close()
{
	//_configFile.
}


void LibConfigMexWrapper::lookup(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	std::string key;
	if (getStringArgument(prhs,2,key))
	{
		int val = 0.0;
		try {
			Setting &setting = _configFile.lookup(key.c_str());
			Setting::Type settingType = setting.getType();

			double *valPtrDbl;
			int64_T *valPtrInt64;
			int *valPtrInt;
			int intVal;
			bool boolVal;
			const char *pcharVal;
			int numElems;

			// ok found it, now return it
			switch (settingType)
			{
			case Setting::TypeNone:
				break;
			case Setting::TypeInt:
				//mexPrintf("'%s' is an int\n",key.c_str());
				//plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
				plhs[0] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
				valPtrInt = static_cast<int*>(mxGetData(plhs[0]));
				intVal = setting;
				*valPtrInt = intVal;
				break;

			case Setting::TypeInt64:
				//mexPrintf("'%s' is a int64\n",key.c_str());

				plhs[0] = mxCreateNumericMatrix(1,1,mxINT64_CLASS,mxREAL);
				valPtrInt64 = static_cast<int64_T*>(mxGetData(plhs[0]));
				intVal = setting;
				*valPtrInt64 = static_cast<double>(intVal);
				break;
			case Setting::TypeFloat:
				plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
				valPtrDbl = mxGetPr(plhs[0]);
				*valPtrDbl = setting;
				break;
			case Setting::TypeString:
				pcharVal = setting;
				plhs[0] = mxCreateCharMatrixFromStrings(1,&pcharVal);
				break;
			case Setting::TypeBoolean:
				/*
				plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
				valPtrDbl = mxGetPr(plhs[0]);
				boolVal = setting;
				if (boolVal)
					*valPtrDbl = 1.0;
				else
					*valPtrDbl = 0.0;
				*/
				plhs[0] = mxCreateLogicalScalar(setting);
				//mexPrintf("'%s' is a bool\n",key.c_str());
				break;

			case Setting::TypeGroup:
				mexPrintf("'%s' is a group. nothing to return.\n",key.c_str());
				break;

      case Setting::TypeArray:
				numElems = setting.getLength();
				if (numElems > 0)
				{
					Setting &elem0 = setting[0];
					Setting::Type elemType = elem0.getType();

					switch (elemType)
					{
          case Setting::TypeInt:
            plhs[0] = mxCreateNumericMatrix(1,numElems,mxINT32_CLASS,mxREAL);
						valPtrInt = static_cast<int*>(mxGetData(plhs[0]));

						for (int j = 0; j < numElems; ++j)
						{
							Setting &elem = setting[j];
							intVal = elem;
							*(valPtrInt++) = static_cast<double>(intVal);
						}
						break;

					case Setting::TypeInt64:
						plhs[0] = mxCreateNumericMatrix(1,numElems,mxINT64_CLASS,mxREAL);
						valPtrInt64 = static_cast<int64_T*>(mxGetData(plhs[0]));

						for (int j = 0; j < numElems; ++j)
						{
							Setting &elem = setting[j];
							intVal = elem;
							*(valPtrInt64++) = static_cast<double>(intVal);;
						}
						break;

					case Setting::TypeFloat:
						plhs[0] = mxCreateDoubleMatrix(1,numElems,mxREAL);

						double dblVal;
						valPtrDbl = mxGetPr(plhs[0]);
						for (int j = 0; j < numElems; ++j)
						{
							Setting &elem = setting[j];
							dblVal = elem;
							*(valPtrDbl++) = dblVal;
						}

						break;

					case Setting::TypeString:
						//pcharVal = setting;
						//plhs[0] = mxCreateCharMatrixFromStrings(1,&pcharVal);
						mexPrintf("'%s' is an array of strings. this shouldn't even be possible\n",key.c_str());
						break;
					}
				}
				break;
			case Setting::TypeList:
				//mexPrintf("'%s' is a list.\n",key.c_str());
				numElems = setting.getLength();
				if (numElems > 0)
				{
					Setting &elem0 = setting[0];
					Setting::Type elemType = elem0.getType();

					switch (elemType)
					{
					case Setting::TypeInt:
					case Setting::TypeInt64:
					case Setting::TypeFloat:
						plhs[0] = mxCreateDoubleMatrix(1,numElems,mxREAL);

						double dblVal;
						valPtrDbl = mxGetPr(plhs[0]);
						for (int j = 0; j < numElems; ++j)
						{
							Setting &elem = setting[j];
							if ((elemType == Setting::TypeInt) || (elemType == Setting::TypeInt64))
							{
								intVal = elem;
								dblVal = static_cast<double>(intVal);
							}
							else
								dblVal = elem;
							//valPtrDbl = mxGetPr(plhs[0]);
							*(valPtrDbl++) = dblVal;
						}

						break;

					case Setting::TypeString:
						//pcharVal = setting;
						//plhs[0] = mxCreateCharMatrixFromStrings(1,&pcharVal);
						mexPrintf("'%s' is a list of strings. currently not supported.\n",key.c_str());
						break;
					}


				}
				break;
			}
		}
		catch (SettingNotFoundException &e)
		{
			mexPrintf("Key not found '%s'",key.c_str());
			mexErrMsgTxt("Requested key not found in config");
		}
	}
	else
		mexErrMsgTxt("Second argument must be a string");
}

void LibConfigMexWrapper::exists(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	std::string key;
	if (getStringArgument(prhs,2,key))
    {
		bool keyExists = _configFile.exists(key.c_str());
		plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
		double *valPtrDbl = mxGetPr(plhs[0]);
		if (keyExists)
			*valPtrDbl = 1.0;
		else
			*valPtrDbl = 0.0;
	}
	else
		mexErrMsgTxt("Second argument must be a string");	
}

void LibConfigMexWrapper::isGroup(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	std::string key;
	if (getStringArgument(prhs,2,key))
  {
    bool isGroup = false;
    bool keyExists = _configFile.exists(key.c_str());
    if (keyExists)
    {
      Setting &setting = _configFile.lookup(key.c_str());
      Setting::Type settingType = setting.getType();
      isGroup = (settingType == Setting::TypeGroup);
    }

    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    double *valPtrDbl = mxGetPr(plhs[0]);
    if (isGroup)
      *valPtrDbl = 1.0;
    else
      *valPtrDbl = 0.0;
  }
  else
    mexErrMsgTxt("Second argument must be a string");
}

void LibConfigMexWrapper::isList(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  std::string key;
  if (getStringArgument(prhs,2,key))
  {
    bool isList = false;
    bool keyExists = _configFile.exists(key.c_str());
    if (keyExists)
    {
      Setting &setting = _configFile.lookup(key.c_str());
      Setting::Type settingType = setting.getType();
      isList = (settingType == Setting::TypeList);
//      if (isList)
//      {
//        mexPrintf("Path of first child: %s\n",setting[0].getPath().c_str());
//        mexPrintf("Name of first child: %s\n",setting[0].getName());
//        try {
//        Setting &test = _configFile.lookup(setting[0].getPath().c_str());
//        mexPrintf("Setting found!\n");
//        }catch(SettingNotFoundException &e){
//          mexPrintf("Setting NOT found!\n");
//        }
//      }
    }

    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    double *valPtrDbl = mxGetPr(plhs[0]);
    if (isList)
      *valPtrDbl = 1.0;
    else
      *valPtrDbl = 0.0;
  }
  else
    mexErrMsgTxt("Second argument must be a string");
}

void LibConfigMexWrapper::getLength(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	std::string key;
	if (getStringArgument(prhs,2,key))
    {
		int len = 0;
		bool keyExists = _configFile.exists(key.c_str());
		if (keyExists)
		{
			Setting &setting = _configFile.lookup(key.c_str());
			len = setting.getLength();
		}

		plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
		double *valPtrDbl = mxGetPr(plhs[0]);
		*valPtrDbl = static_cast<double>(len);
	}
	else
		mexErrMsgTxt("Second argument must be a string: the name of the setting");	
}

void LibConfigMexWrapper::getSubSettingNameByIdx(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	std::string key;
	if (getStringArgument(prhs,2,key))
    {
		double idx = 0;
		if (getDoubleArgument(prhs,3,idx))
		{
			int iidx = static_cast<int>(floor(idx));
			std::string settingName = "";
			bool keyExists = _configFile.exists(key.c_str());
			if (keyExists)
			{
				Setting &setting = _configFile.lookup(key.c_str());
				if (setting.getLength() > iidx)
					settingName = setting[iidx].getName();
			}

			plhs[0] = mxCreateString(settingName.c_str());
		}
		else
			mexErrMsgTxt("Third argument must be an integer indicating the index of the setting within the group");
	}
	else
		mexErrMsgTxt("Second argument must be a string: the name of the setting");	
}

bool LibConfigMexWrapper::getStringArgument(const mxArray *prhs[], int idx, std::string &argStr)
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

bool LibConfigMexWrapper::getDoubleArgument(const mxArray *prhs[], int idx, double &val)
{
    if (!mxIsNumeric(prhs[idx]))
        return false;

	val = mxGetScalar(prhs[idx]);
    return true;
}

