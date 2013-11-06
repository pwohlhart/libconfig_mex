/*
 * LibConfigMexWrapper.h
 *
 *  Created on: 20.12.2010
 *      Author: pwohlhart
 */

#ifndef LIBCONFIGMEXWRAPPER_H_
#define LIBCONFIGMEXWRAPPER_H_

#include "mex.h"
#include <string>
#include <libconfig.h++>

using namespace libconfig;

class LibConfigMexWrapper {
public:
	LibConfigMexWrapper();
	virtual ~LibConfigMexWrapper();

	static LibConfigMexWrapper *retrieveAndCheckPtr(int inputSize, const mxArray *input[]);
	bool readFile(std::string filename);
	void close();

	void lookup(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
	void exists(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
	void isGroup(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
	void getLength(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
	void getSubSettingNameByIdx(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
private:
	Config _configFile;

	bool getStringArgument(const mxArray *prhs[], int idx, std::string &argStr);
	bool getDoubleArgument(const mxArray *prhs[], int idx, double &val);
};

#endif /* LIBCONFIGMEXWRAPPER_H_ */
