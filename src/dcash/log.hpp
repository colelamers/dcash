#ifndef LOG_H
#define LOG_H

#include <string>
#include <string_view>
#include <mutex>
#include <filesystem> 
#include "spdlog/spdlog.h"

namespace helper {
    class log {
    public:
        // Singleton
        static log& instance();
        static log& instance(int level);
        log(const log&) = delete;
        log(log&&) = delete;
        log& operator=(const log&) = delete;
        log& operator=(log&&) = delete;
        void critical(const std::string& message);
        void critical_wf(const std::string& message);
        void debug(const std::string& message);
        void debug_wf(const std::string& message);
        void error(const std::string& message);
        void error_wf(const std::string& message);
        void info(const std::string& message);
        void info_wf(const std::string& message);
        void trace(const std::string& message);
        void trace_wf(const std::string& message);
        void warn(const std::string& message);
        void warn_wf(const std::string& message);
        void set_log_title(const std::string& name);
        void set_spdlog_level(int level);
        spdlog::level::level_enum get_spdlog_level();
        std::string get_log_path();
        std::string get_log_file_path();
        std::string get_log_title();
        std::string get_log_file(const std::string& log_file_title);
        std::string get_time();
        std::string get_log_type(spdlog::level::level_enum level);
    private:
        log(int level);
        const std::string _default_dir = "logs";
        std::filesystem::path _path;
        std::string _current_log_file_title;
        std::filesystem::path _file_path;
        int _log_level;
        std::mutex _write_mutex;
        void create_log_file();
        void create_log_file(const std::string& custom);
        void write_to_file(spdlog::level::level_enum loglev, const std::string& message);
    };
}

#endif
