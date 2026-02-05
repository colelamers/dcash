#ifndef XML_H
#define XML_H

#include <filesystem>
#include <string>
#include <vector>
#include <map>
#include <mutex>

#include "pugixml.hpp"

namespace helper {
    class xml {
    public:
        xml();
        xml(const std::string& fully_qualified_path);
        //~xml();
        std::string get_default_conf();
        std::string get_conf(const std::string& default_dir);
        std::map<std::string, std::string> get_node_attributes(pugi::xml_node node);
        void load_default();
        void load_from_file(const std::string& fully_qualified_path);
        pugi::xml_document load_separate(const std::string& fully_qualified_path);
        void write();
        void write(const std::string& fully_qualified_path);
        void create();
        std::vector<pugi::xml_node> nodes_by_xpath(const std::string& expr);
        std::vector<pugi::xml_node> all_by_tag(const std::string& tag);
        pugi::xml_node node_by_path(const std::vector<std::string>& path);
        std::filesystem::path get_full_path();
        std::vector<pugi::xml_node> children_by_path(const std::vector<std::string>& path, 
                                                     const std::string&              child_tag);
        std::vector<pugi::xml_node> children_by_path(std::initializer_list<std::string> path, 
                                                     const std::string&                 child_tag);
        pugi::xml_node node_by_path(std::initializer_list<std::string> path);
        pugi::xml_node find_node_by_attribute(const std::string& tag, 
                                              const std::string& attr_name, 
                                              const std::string& attr_val);
        void set_xml_file(std::string& xml_filename_only);
        void set_xml_path(std::string& xml_path_only);
        void set_xml_fully_qualified_path(std::string& xml_fully_qualified_path);
        const std::string default_dir() const;
        pugi::xml_document& xml_doc();
        // std::string xml_file_name(); todo;
        std::filesystem::path full_path();
        std::mutex& write_mutex();
        std::string set_default_dir();
        void set_xml_doc(std::string path);
        // std::string set_xml_file_name(); todo;
        // std::filesystem::path set_full_path(); todo; idk that i want this, i want it only on
        // init
    private:
        xml(const xml&) = delete; // xml a; xml b = a; xml c(a); // ERRORS
        xml& operator=(const xml&) = delete; // xml a, b; b = a; // ERROR
        xml(xml&&) noexcept = default; // xml a; xml b = std::move(a); // OK
        xml& operator=(xml&&) noexcept = delete; // xml a, b; xml b = std::move(a); // OK
        pugi::xml_document xml_doc_;
        // std::string xml_file_name_; todo; gonna do something with this at one point?
        std::filesystem::path full_path_;
        std::mutex write_mutex_;
    };
}
#endif
