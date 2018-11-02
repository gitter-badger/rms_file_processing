#include <iostream>
#include "hash.h"

using namespace std;

THash tHash;

int Initialize(){
    tHash.BuildInit();
    return 0;
}

int unInitialize(){
    tHash.BuildUnInit();
    return 0;
}

int main() {
//    std::cout << "Hello, World!" << std::endl;
        Initialize();
        tHash.File2Hash("op.wma");
        unInitialize();
    return 0;
}