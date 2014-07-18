//
//  DownloadSqlProcess.m
//  PudongTravel
//
//  Created by mark on 14-5-5.
//  Copyright (c) 2014年 mark. All rights reserved.
//

#import "DownloadSqlProcess.h"
#include <sqlite3.h>
//
//  DownloadSqlProcess.cpp
//  localLanguage
//
//  Created by 何 清龙 on 13-9-16.
//
//

DownloadSqlProcess *DownloadSqlProcess::m_instance = NULL;

DownloadSqlProcess *DownloadSqlProcess::instance(){
    if(m_instance == NULL){
        m_instance = new DownloadSqlProcess;
        m_instance->init();
    }
    return m_instance;
}

sqlite3 * DownloadSqlProcess::creatTable(){
    NSArray *downloadDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    std::string dir = [((NSString*)downloadDir[0]) UTF8String];
    
    //该死的dir不含有凡斜杠"/"导致我一直找问题，又没有注意输出，因为输出换行了。
    std::string path =  dir + "/voices.sql";
	//打开一个数据库，如果该数据库不存在，则创建一个数据库文件
	result = sqlite3_open_v2(path.c_str(), &pDB, SQLITE_OPEN_READWRITE| SQLITE_OPEN_CREATE, NULL);
    
	if( result != SQLITE_OK ){
        NSLog(@"%s", sqlite3_errmsg(pDB));
        NSLog( @"打开数据库失败，错误码:%d ，错误原因:%s\n" , result, errMsg );
        sqlite3_close(pDB);
    }

    
	//创建表，设置voidId为主键
    sqlCommand = std::string("CREATE TABLE IF NOT EXISTS " + m_table_name + "(voiceId TEXT,area TEXT,title TEXT,imgUrl TEXT,voiceUrl TEXT,soundFile TEXT)");

	result=sqlite3_exec( this->pDB, sqlCommand.c_str(), NULL, NULL, &errMsg );
	if( result != SQLITE_OK ){
        NSLog(@"%s", sqlCommand.c_str());
        NSLog(@"%s", sqlite3_errmsg(pDB));
        NSLog( @"创建数据库失败，错误码:%d ，错误原因:%s\n" , result, errMsg );
    }
	return this->pDB;
}

void DownloadSqlProcess::dropTable(){
    std::string drop_command = "drop table ";
    sqlCommand = drop_command + m_table_name;
    sqlite3_exec( pDB, sqlCommand.c_str(), NULL, NULL, &errMsg);
}

bool DownloadSqlProcess::init(){
    errMsg = new char[100];
    m_table_name = "SoundInfo";
    pDB = creatTable();
    return true;
}

int DownloadSqlProcess::insertElement(const Element &elem){
    std::string sqlstr=" insert into " + m_table_name + "(voiceId,area,title,imgUrl,voiceUrl) values ( \'"
    + elem.voiceId + "\',\'"
    + elem.area + "\',\'"
    + elem.title + "\',\'"
    + elem.imgUrl + "\',\'"
    + elem.voiceUrl + "\'"
    + ")";
    NSLog(@"%s", sqlstr.c_str());
    
    result = sqlite3_exec( pDB, sqlstr.c_str() , NULL, NULL, &errMsg );
    if(result != SQLITE_OK )
        NSLog( @"插入记录失败，错误码:%d ，错误原因:%s\n" , result, errMsg );
    return result;
}

int DownloadSqlProcess::deleteElement(const Element &elem){
    sqlCommand ="delete from " + m_table_name + " where voiceId=\'" + elem.voiceId + "\' and title=\'" + elem.title + "\' and voiceUrl=\'" + elem.voiceUrl + "\'";
    result = sqlite3_exec( pDB, sqlCommand.c_str() , NULL, NULL, &errMsg );
    NSLog(@"%s", sqlCommand.c_str());
    if(result != SQLITE_OK )
        NSLog( @"删除记录失败，错误码:%d ，错误原因:%s\n" , result, errMsg );
    return result;
}

void DownloadSqlProcess::deleteAllElements(){
    NSArray *downloadDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    std::string dir = [((NSString*)downloadDir[0]) UTF8String];
    std::vector<Element> elems = this->readElements();
    for(int i = 0; i < elems.size(); ++i){
        this->deleteElementAtIndex(i);
    }
    this->dropTable();
    this->creatTable();
}

int DownloadSqlProcess::deleteElementAtIndex(unsigned int index){
    Element elem = this->readElements()[index];
    if(elem.soundFile != ""){
        NSArray *downloadDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fullPath = downloadDir[0];
        fullPath = [fullPath stringByAppendingFormat:@"%s", elem.soundFile.c_str()];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
    return this->deleteElement(elem);
}
static int loadElement(void *para, int n_column, char **column_value, char **column_name){
    auto elements = static_cast<std::vector<Element> *>(para);
    Element elem;
    elem.voiceId = column_value[0];
    elem.area = column_value[1];
    elem.title = column_value[2];
    elem.imgUrl = column_value[3];
    elem.voiceUrl = column_value[4];
    
    if(elem.soundFile == "file"){
            //elem.soundFile = elem.soundFile;
    }else{
        int Pos = elem.voiceUrl.find_last_of('/');
        if (Pos < 0)
            exit(-1);
        elem.soundFile = elem.voiceUrl.substr(Pos+1);
    }

    NSLog(@"voiceId=%s, title=%s, voiceUrl = %s, soundFile = %s",
          elem.voiceId.c_str(), elem.title.c_str(), elem.voiceUrl.c_str(), elem.soundFile.c_str());
    
    elements->push_back(elem);
    return 0;
}

void DownloadSqlProcess::showAllDataInTable(){
    dbElements.clear();
    sqlCommand = "select * from " + m_table_name;
    if( SQLITE_OK == sqlite3_exec( pDB, sqlCommand.c_str(), loadElement, &dbElements, &errMsg ))
        NSLog(@"select the sounds successful!");
}

std::vector<Element> DownloadSqlProcess::readElements(){
    dbElements.clear();
    sqlCommand = "select * from " + m_table_name;
    if( SQLITE_OK == sqlite3_exec( pDB, sqlCommand.c_str(), loadElement, &dbElements, &errMsg )){
        NSLog(@"select the sounds successful!");
    }else{
        NSLog( @"查询所有记录失败，错误码:%d ，错误原因:%s\n" , result, errMsg );
    }
    return dbElements;
}

Data * convertElement2Info(Element &elem){
    Data *info = [Data new];
    /*
    info->title    = [NSString stringWithUTF8String:elem.title.c_str()];
    info->area     = [NSString stringWithUTF8String:elem.area.c_str()];
    info->imgUrl   = [NSString stringWithUTF8String:elem.imgUrl.c_str()];
    info->voiceId  = [NSString stringWithUTF8String:elem.voiceId.c_str()];
    info->voiceUrl = [NSString stringWithUTF8String:elem.voiceUrl.c_str()];
    info->fileName = [NSString stringWithUTF8String:elem.soundFile.c_str()];
     */
    return info;
}
Element convertInfo2Element(Data *info){
    Element elem;
    /*
    elem.area      = info->area ? [info->area UTF8String] : "";
    elem.imgUrl    = info->imgUrl ? [info->imgUrl UTF8String] : "";
    elem.voiceId   = info->voiceId ? [info->voiceId UTF8String] : "";
    elem.voiceUrl  = info->voiceUrl ? [info->voiceUrl UTF8String] : "";
    elem.title     = info->title ? [info->title UTF8String] : "";
    elem.soundFile = info->fileName ? [info->fileName UTF8String] : "";
     */
    return elem;
}