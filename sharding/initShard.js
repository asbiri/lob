    // note: never use "localhost", or aliases for it, for production.  but for a 1 machine dev test it is ok.
    var x = rs.initiate(                                                         
        { _id:'rs1',                                                               
          members:[                                                              
            { _id:1, host:'localhost:27001' },                                   
            { _id:2, host:'localhost:27002' },                                   
            { _id:3, host:'localhost:27003' }                                    
          ]                                                                      
        }
    );                                                                           
    printjson(x);                                                                
    print('waiting for set to initiate...');                                     
    while( 1 ) {                                                                 
        sleep(2000);                                                             
        x = db.isMaster();                                                       
        printjson(x);                                                            
        if( x.ismaster || x.secondary ) {
            print("ok, this member is online now; that doesn't mean all members are ");
            print("ready yet though.");
            break;                                                               
        }                                                                        
    }                                                                            

