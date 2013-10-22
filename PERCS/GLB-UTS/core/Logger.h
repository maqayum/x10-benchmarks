#ifndef __CORE_LOGGER_H
#define __CORE_LOGGER_H

#include <x10rt.h>


#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
namespace x10 { namespace util { 
class Team;
} } 
namespace x10 { namespace util { 
class Timer;
} } 
namespace x10 { namespace lang { 
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace io { 
class Printer;
} } 
namespace x10 { namespace io { 
class Console;
} } 
namespace x10 { namespace lang { 
class Any;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace lang { 
class Runtime;
} } 
namespace core { 

class Logger : public x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    x10_long FMGL(nodesCount);
    
    x10_long FMGL(nodesGiven);
    
    x10_long FMGL(stealsAttempted);
    
    x10_long FMGL(stealsPerpetrated);
    
    x10_long FMGL(stealsReceived);
    
    x10_long FMGL(stealsSuffered);
    
    x10_long FMGL(nodesReceived);
    
    x10_long FMGL(lifelineStealsAttempted);
    
    x10_long FMGL(lifelineStealsPerpetrated);
    
    x10_long FMGL(lifelineStealsReceived);
    
    x10_long FMGL(lifelineStealsSuffered);
    
    x10_long FMGL(lifelineNodesReceived);
    
    x10_long FMGL(lastStartStopLiveTimeStamp);
    
    x10_long FMGL(timeAlive);
    
    x10_long FMGL(timeDead);
    
    x10_long FMGL(startTime);
    
    x10_long FMGL(timeReference);
    
    void _constructor(x10_boolean b);
    
    static core::Logger* _make(x10_boolean b);
    
    virtual void startLive();
    virtual void stopLive();
    virtual void collect(x10::lang::Rail<core::Logger* >* logs);
    virtual void stats(x10_long time);
    static x10::lang::String* sub(x10::lang::String* str, x10_int start, x10_int end);
    virtual void add(core::Logger* other);
    virtual core::Logger* get(x10_boolean verbose);
    virtual core::Logger* core__Logger____this__core__Logger();
    virtual void __fieldInitializers_core_Logger();
    
    // Serialization
    public: static const x10aux::serialization_id_t _serialization_id;
    
    public: virtual x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(x10aux::serialization_buffer& buf);
    
    public: static x10::lang::Reference* _deserializer(x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(x10aux::deserialization_buffer& buf);
    
};


} 
#endif // CORE_LOGGER_H

namespace core { 
class Logger;
} 

#ifndef CORE_LOGGER_H_NODEPS
#define CORE_LOGGER_H_NODEPS
#ifndef CORE_LOGGER_H_GENERICS
#define CORE_LOGGER_H_GENERICS
#endif // CORE_LOGGER_H_GENERICS
#endif // __CORE_LOGGER_H_NODEPS