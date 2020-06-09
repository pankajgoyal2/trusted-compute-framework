import argparse

def get_test_data(test_array, count):
    result_array = []
    for line in test_array[count:]:
        result_array.append(line)
        if "Test Completed" in line:
            break
    return result_array

#argumentList=sys.argv
#print(argumentList)
#outputfile=sys.argv[1]
#print(outputfile)

parser = argparse.ArgumentParser()
parser.add_argument("-o", "--outputfile",
                     help="outputfile having test results",
                     type=str, default=None)
options = parser.parse_args()
if options.outputfile:
    resultfile=options.outputfile
    print(resultfile)
else:
    print("ERROR: Please enter the outputfile")
final_res = {'QCID_18393': 'NA', 'QCID_18402': 'NA', \
             'QCID_18404': 'NA', \
             'QCID_18396': 'NA', 'QCID_18397': 'NA', \
             'QCID_18395': 'NA', 'QCID_18403': 'NA', \
             'QCID_18406': 'NA', 'QCID_18394': 'NA', \
             'QCID_18411': 'NA', \
             'QCID_18422': 'NA', 'QCID_18439': 'NA', \
             'QCID_18430': 'NA', 'QCID_18429': 'NA', \
             'QCID_18428': 'NA', 'QCID_18437': 'NA', \
             'QCID_20315': 'NA', 'QCID_20316': 'NA', \
             'QCID_20317': 'NA', 'QCID_18401': 'NA', \
             'QCID_20318': 'NA', 'QCID_20319': 'NA', \
             'QCID_18436': 'NA', 'QCID_20320': 'NA'}
test_dict = {'QCID_18393': 'Hello', \
             'QCID_18402': 'You have a 47% risk of heart disease', \
             'QCID_18404': 'Invalid data found in input data', \
             'QCID_18396': 'Hello12345', \
             'QCID_18397': '12345678', 'QCID_18395': '     ', \
             'QCID_18403': 'Invalid data found in input data', \
             'QCID_18406': 'JMeter is a performance test tool.', \
             'QCID_18394': '#@!$%@#&*()$%#', \
             'QCID_18411': 'Error with missing or incorrect input format', \
             'QCID_18422': 'Invalid workload id', \
             'QCID_18439': 'Workload id is mandatory', \
             'QCID_18430': 'You have a 47% risk of heart disease', \
             'QCID_18429': 'Error with missing or incorrect input format', \
             'QCID_18428': 'Heart disease risk is',  \
             'QCID_18437': 'Cannot encrypt the empty message', \
             'QCID_20315': 'Cannot encrypt the empty message', \
             'QCID_20316': 'Worker Id not found in the database.', \
             'QCID_20317': 'Worker Id not found in the database.', \
             'QCID_18401': 'Temporary failure in name resolution', \
             'QCID_20318': 'RequesterSignatureEnabled1', 'QCID_20319': 'You have a 47% risk of heart disease', \
             'QCID_18436': 'Worker Id not found in the database', \
             'QCID_20320': 'Invalid workload id'}
for test_name, test_value in test_dict.items():
    file_contents = open(resultfile, "r")
    filedata = file_contents.readlines()
    for line in filedata:
        if test_name in line:
            print("Test Found")
            flag = True
            break
        else:
            flag = False
    if flag:
        line_num = [filedata.index(ele) for ele in filedata if(test_name in ele)]
        #print(line_num[0])
        test_results = get_test_data(filedata, line_num[0])
        result1 = [ele for ele in test_results if (test_value in ele)]
        if (result1):
            print("Test Passed", test_name)
            temp_dict={test_name: 'Pass'}
            final_res.update(temp_dict)
        else:
            print("Test Failed", test_value)
            temp_dict={test_name: 'Fail'}
            final_res.update(temp_dict)
        #print(test_value in result)
        #print(test_name, result)
    else:
        print("This test didnt run in this mode", test_name)
print("**********FINAL RESULT********", final_res)

Passcount=0
Failcount=0
NAcount=0

for res in final_res.values():
    #print(res)
    if res=='Pass':
        Passcount = Passcount+1
    elif res=='Fail':
        Failcount = Failcount+1
    else:
        NAcount = NAcount+1
print("********Total Tests Passed********", Passcount)
print("********Total Tests Failed********", Failcount)
print("********Total NA Tests********", NAcount)

