//
// Created by anjana on 10/10/18.
//

#ifndef ENGINE_HASH_H
#define ENGINE_HASH_H

/*-------------------------- hash structures ---------------------------*/

/*#ifndef _HashFunc_h_
#define _HashFunc_h_*/

#include "stdlib.h"
#include "memory.h"
#include "stdio.h"
#include "assert.h"
#include "string.h"
#include <iostream>


#define ID_BITS 18				//Basically, there are a total of 260,000 songs (if the server memory is large enough)...
#define OFFSET_BITS 14			//By default each song is less than 8.7 minutes.
#define MAX_SONG_NUM (2<<18)
#define MAX_SONG_LEN 256
#define HashKeyNum (1<<20)
#define ValuePerBlock (1<<6)	//The size of each memory space (64*sizeof(size_t)) is used to store multiple value values in the hash bucket and can be expanded.
#define BlockNum 4				//Block value for dynamic capacity expansion.
#define OverFlowThreshold 1<<28
using namespace std;

//Hash key type for Build
//(f1, f2_f1, t)
struct HashKeyInfo{
    size_t* start;
    size_t length;
    HashKeyInfo* next;	//Pointer for expansion
};
//Hash key type for Recog
struct HashKeyTable{
    size_t *start;
    size_t length;
};

class THash{
private:
public:
    size_t *pValueStart;
    size_t *pValueEnd;
    short **vote_table;
    size_t data_num;
    char **song_list;
    size_t song_num;
    HashKeyInfo *key_info;
    HashKeyTable *key_table;

    THash();
    ~THash();
    void ReBuildInit();
/************************************  Functions for build tracks.(iFlyBuild) ************************************************/
    //This function is used in the case of iFlyBuild, from wav to Hash_Table.				//Finished.
    void BuildInit();
    void BuildUnInit();
    //Add the song name and update the number of songs.										//Finished.
    void AddSongList(const char *filename);
    //Add data to the Value memory block and update Key_table.						//Finished.
    void InsertHash(size_t f1, size_t f2_f1, size_t t, size_t id, size_t offset);
    //Brush the hash table to the file (not to brush the entire memory, this will waste memory space in iFlySelect)//Finished
    void Hash2File(const char* filename);

/************************************  Functions for select tracks.(iFlySelect) ************************************************/
    size_t* GetHash(size_t f1, size_t f2_f1, size_t t);
    void File2Hash(const char* filename);
    //Functions for vote and save the top voted id to QueryId.
    void VoteInit();
    void Vote(size_t f1, size_t f2_f1, size_t t, size_t offset);
    size_t VoteResult(size_t &offset);
};


#endif //ENGINE_HASH_H
