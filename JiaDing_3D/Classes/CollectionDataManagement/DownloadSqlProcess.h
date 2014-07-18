//
//  DownloadSqlProcess.h
//  PudongTravel
//
//  Created by mark on 14-5-5.
//  Copyright (c) 2014年 mark. All rights reserved.
//
#include <iostream>
#include <sqlite3.h>
#include <vector>

#ifndef __DownloadSqlProcess__
#define __DownloadSqlProcess__
#import "Data.h"

struct Element{
    std::string voiceId;
    std::string area;
    std::string title;
    std::string imgUrl;
    std::string voiceUrl;
    
    std::string soundFile;
};
Data * convertElement2Info(Element &elem);
Element convertInfo2Element(Data *info);

//单件模式
class DownloadSqlProcess{
public:
    static DownloadSqlProcess *instance();
    
    int insertElement(const Element &elem);
    int deleteElementAtIndex(unsigned int index);
    void deleteAllElements();
    
    std::vector<Element> readElements();
    void showAllDataInTable();
protected:
    int deleteElement(const Element &elem);
    DownloadSqlProcess(){}//构造函数
    void operator=( DownloadSqlProcess &){}
    bool init();
    sqlite3 * creatTable();
    void dropTable();
private:
    static DownloadSqlProcess * m_instance;
    
    std::vector<Element> dbElements;
    sqlite3 *pDB;  //数据库指针
    char * errMsg ;  //错误信息
    std::string sqlCommand;  //SQL指令
	int result;  //sqlite3_exec返回值
    
    std::string m_table_name;
};
#endif /* defined(__localLanguage__DownloadSqlProcess__) */
