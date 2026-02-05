#include <chrono>
#include <format>
#include <string_view>
#include <string>

#include "log.hpp"
#include "spdlog/spdlog.h"
#include "spdlog/sinks/basic_file_sink.h"
#include "app_path.hpp"

namespace helper {
    log& 
    log::instance() {
        // Logging by default without being explicit assumes trace everything
        static log l(1);
        return l;
    }

    log& 
    log::instance(int level) {
        static log l(level);
        return l;
    }

    log::log(int level) :
        _path(app_path::get_fully_qualified_dir_path(_default_dir)),
        _current_log_file_title(app_path::get_project_name()),
        _file_path(get_log_file(app_path::get_project_name())),
        _log_level(level) {
            set_spdlog_level(this->_log_level);
            // Set Console Pattern. This is how I like it.
            spdlog::set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%^%l%$] %v");
    }

    std::string 
    log::get_log_path() {
        // project_root/log
        return this->_path;
    }

    std::string 
    log::get_log_file_path() {
        // project_root/log
        return this->_file_path;
    }

    void 
    log::debug(const std::string& message) {
        spdlog::log(spdlog::level::debug, message);
    }

    void 
    log::debug_wf(const std::string& message) {
        write_to_file(spdlog::level::debug, message);
    }

    void 
    log::trace(const std::string& message) {
        spdlog::log(spdlog::level::trace, message);
    }

    void 
    log::trace_wf(const std::string& message) {
        write_to_file(spdlog::level::trace, message);
    }

    void 
    log::critical(const std::string& message) {
        spdlog::log(spdlog::level::critical, message);
    }
    void 
    log::critical_wf(const std::string& message) {
        write_to_file(spdlog::level::critical, message);
    }

    void 
    log::error(const std::string& message) {
        spdlog::log(spdlog::level::err, message);
    }

    void 
    log::error_wf(const std::string& message) {
        write_to_file(spdlog::level::err, message);
    }
    
    void 
    log::info_wf(const std::string& message) {
        write_to_file(spdlog::level::info, message);
    }

    void 
    log::info(const std::string& message) {
        spdlog::log(spdlog::level::info, message);
    }

    void 
    log::warn(const std::string& message) {
        spdlog::log(spdlog::level::warn, message);
    }

    void 
    log::warn_wf(const std::string& message) {
        write_to_file(spdlog::level::warn, message);
    }

    void 
    log::set_spdlog_level(int level) {
        switch (level){
            case 1:
                spdlog::set_level(spdlog::level::trace);
                break;
            case 2:
               spdlog::set_level(spdlog::level::debug);
                break;
            case 3:
               spdlog::set_level(spdlog::level::info);
                break;
            case 4:
               spdlog::set_level(spdlog::level::warn);
                break;
            case 5:
               spdlog::set_level(spdlog::level::err);
                break;
            case 6:
               spdlog::set_level(spdlog::level::critical);
                break;
            case 7:
               spdlog::set_level(spdlog::level::off);
                break;
            default:
               spdlog::set_level(spdlog::level::trace);
                break;
        }
    }

    spdlog::level::level_enum 
    log::get_spdlog_level() {
        switch (this->_log_level) {
            case 1:
                return spdlog::level::trace;
            case 2:
               return spdlog::level::debug;
            case 3:
               return spdlog::level::info;
            case 4:
               return spdlog::level::warn;
            case 5:
               return spdlog::level::err;
            case 6:
               return spdlog::level::critical;
            case 7: // defulat off if not defined
            default:
               return spdlog::level::off;
        }
    }

    std::string 
    log::get_log_file(const std::string& log_title) {
        auto now = std::chrono::system_clock::now();
        // Convert now to local time zone
        std::chrono::zoned_time local_time{std::chrono::current_zone(), now};
        // Floor to days to get local midnight
        std::chrono::year_month_day ymd{floor<std::chrono::days>(local_time.get_local_time())};
        std::string date_str = std::format("{:%Y%m%d}", ymd);
        std::string log_filename = std::string(log_title) + "_" + date_str + ".log";
        std::filesystem::path final_path = app_path::get_fully_qualified_dir_path(_default_dir) / log_filename;
        return final_path.string();
    }

    void 
    log::write_to_file(spdlog::level::level_enum level, const std::string& message) {
        std::lock_guard<std::mutex> lock(_write_mutex);
        const auto name = get_log_title();
        const auto path = get_log_file(name);
        auto logger = spdlog::get(name);
        if (!logger) {
            app_path::create_file(path);
            logger = spdlog::basic_logger_mt(name, path);
            logger->set_level(get_spdlog_level());
            logger->set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%n] [%^%l%$] %v");
        }
        logger->log(level, std::string(message));
        logger->flush(); // ensure when done it writes to file
    }

    // todo; this can definitely be revised
    std::string 
    log::get_log_type(spdlog::level::level_enum level) {
        switch (level) {
            case spdlog::level::critical:
                return "CRITICAL";
            case spdlog::level::err:
                return "ERROR";
            case spdlog::level::warn:
                return "WARNING";
            case spdlog::level::info:
                return "INFO";
            case spdlog::level::debug:
                return "DEBUG";
            case spdlog::level::trace:
                return "TRACE";
            case spdlog::level::off:
                return "OFF";
            default:
                return "TYPE UNKNOWN! CRITICAL LOG ERROR!";
        }
    }

    std::string 
    log::get_time() {
        auto now = std::chrono::system_clock::now();
        auto in_time_t = std::chrono::system_clock::to_time_t(now);
        std::tm buf;
    #ifdef _WIN32
        localtime_s(&buf, &in_time_t);
    #else
        localtime_r(&in_time_t, &buf);
    #endif
        // Get Milliseconds
        std::chrono::milliseconds ms = std::chrono::duration_cast<std::chrono::milliseconds>(
            now.time_since_epoch()) % std::chrono::milliseconds(1000);
        // todo; see if you can get rid of stream
        std::ostringstream timestamp;
        timestamp << std::put_time(&buf, "[%H:%M.") 
                  << std::setw(3) 
                  << std::setfill('0') 
                  << ms.count();
        return timestamp.str() + "]";
    }

    std::string 
    log::get_log_title() {
        return this->_current_log_file_title;
    }

    void 
    log::set_log_title(const std::string& name) {
        this->_current_log_file_title = std::string(name);
    }
}
