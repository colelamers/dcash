#include <iostream>
#include <string>

#include "pugixml.hpp"
#include "strex.hpp"
#include "xml.hpp"
#include "app_path.hpp"

/*
PUGI_XML Notes
Category    Task                                Method / Syntax
Metadata
            Get the tag name                    node.name()
            Get node type (element, pcdata)     node.type()
            Check if node is valid/exists       if (node) or !node.empty()
            Get parent node                     node.parent()
Data Access
            Get text inside <tag>Text</tag>     node.child_value()
            Get a specific attribute            node.attribute("name")
            Get attribute value as string       node.attribute("name").value()
            Get attribute value as integer      node.attribute("name").as_int()
            Access text object for converters   node.text()
Navigation    
            Find first child with tag name      node.child("name")
            Find next sibling with same tag     node.next_sibling("name")
            Move to previous sibling            node.previous_sibling()
            Iterate all children                node.children()
Setters
            Change existing attribute value     node.attribute("name").set_value("new")
            Change tag name                     node.set_name("new_tag_name")
            Set/Update text inside tag          node.text().set("new_text")
            Add a new attribute                 node.append_attribute("name")
            Add a new child tag                 node.append_child("tag_name")
            Remove attribute                    node.remove_attribute("name")
            Remove child tag                    node.remove_child("name")
*/

namespace helper {
    // _default_dir is a relative folder path below the project name path
    xml::xml() 
    : full_path_(app_path::get_fully_qualified_dir_path(default_dir())) {
        if (!app_path::verify_exists(full_path())) {
            app_path::create_file(full_path());
        }
        xml::load_default();
        // write_mutex_.lock();
    }

    xml::xml(const std::string& fully_qualified_path) 
    : full_path_(fully_qualified_path) {
        if (!app_path::verify_exists(full_path())) {
            app_path::create_file(full_path());
        }
        xml::load_from_file(full_path());
        // write_mutex_.lock();
    }

    /*xml::~xml(){
        write_mutex_.unlock();
    }*/

    std::filesystem::path xml::get_full_path() {
        return full_path();
    }

    std::string xml::get_default_conf() {
        // Process:
        // ~/project
        // project.xml
        // ~/project/config/project.xml
        std::string conf_filename = app_path::get_project_name() + ".xml";
        std::filesystem::path final_path = app_path::get_fully_qualified_dir_path(
            default_dir()) / conf_filename;
        return final_path.string();
    }

    std::string xml::get_conf(const std::string& config_file_name) {
        // Process:
        // ~/project
        // project.xml
        // ~/project/config/project.xml
        std::string conf_filename = config_file_name + ".xml";
        std::filesystem::path final_path = app_path::get_fully_qualified_dir_path(
            default_dir()) / conf_filename;
        return final_path.string();
    }

    std::map<std::string, std::string> xml::get_node_attributes(pugi::xml_node node) {
        std::map<std::string, std::string> attributes;
        // Basically, start at first index, hold index in place, and next index
        // rvalue overrides until no more next indexes exist
        for (pugi::xml_attribute attr = node.first_attribute(); attr; attr = attr.next_attribute()) {
            attributes[attr.name()] = attr.value();
        }
        return attributes;
    }

    void xml::load_default() {
        std::lock_guard<std::mutex> lock(write_mutex());
        set_xml_doc(get_default_conf());
    }

    void xml::load_from_file(const std::string& fully_qualified_path) {
        std::lock_guard<std::mutex> lock(write_mutex()); // lock
        set_xml_doc(fully_qualified_path);
    }

    pugi::xml_document xml::load_separate(const std::string& fully_qualified_path) {
        std::lock_guard<std::mutex> lock(write_mutex()); // lock
        pugi::xml_document t_doc;
        t_doc.load_file(fully_qualified_path.c_str());
        return t_doc;
    }

    void xml::write() {
        std::lock_guard<std::mutex> lock(write_mutex()); // lock
        xml_doc().save_file(xml::get_default_conf().c_str());
    }

    void xml::write(const std::string& fully_qualified_path) {
        std::lock_guard<std::mutex> lock(write_mutex()); // lock
        xml_doc().save_file(fully_qualified_path.c_str());
    }

    // doc.nodes_by_xpath("/root/*/child");
    // doc.nodes_by_xpath("//thing2/child");
    std::vector<pugi::xml_node> xml::nodes_by_xpath(const std::string& expr) {
        std::vector<pugi::xml_node> out;

        pugi::xpath_node_set nodes = xml_doc().select_nodes(expr.c_str());
        for (const pugi::xpath_node& xn : nodes) {
            out.push_back(xn.node());
        }

        return out;
    }

    std::vector<pugi::xml_node> xml::all_by_tag(const std::string& tag) {
        std::vector<pugi::xml_node> out;

        std::string xpath = "//" + tag;
        pugi::xpath_node_set nodes = xml_doc().select_nodes(xpath.c_str());

        for (const pugi::xpath_node& xn : nodes) {
            out.push_back(xn.node());
        }

        return out;
    }

    // std::vector<std::string> path = { "root", "thing1", "child" };
    // pugi::xml_node n = doc.node_by_path(path);
    pugi::xml_node xml::node_by_path(const std::vector<std::string>& path) {
        pugi::xml_node t_node = xml_doc();
        for (const std::string& tag : path) {
            t_node = t_node.child(tag.c_str());
            if (!t_node) {
                return {};
            }
        }

        return t_node;
    }

    // std::vector<std::string> parent_path = { "root", "thing1" };
    // std::vector<pugi::xml_node> children = doc.children_by_path(parent_path, "child");
    std::vector<pugi::xml_node> xml::children_by_path(
        const std::vector<std::string>& path, 
        const std::string& child_tag) {
        std::vector<pugi::xml_node> out;
        pugi::xml_node parent = node_by_path(path);

        if (!parent) {
            return out;
        }

        for (pugi::xml_node c : parent.children(child_tag.c_str())) {
            out.push_back(c);
        }

        return out;
    }

    // auto n = doc.node_by_path({ "root", "thing1", "child" });
    pugi::xml_node xml::node_by_path(std::initializer_list<std::string> path) {
        pugi::xml_node t_node = xml_doc();
        for (const std::string& tag : path) {
            t_node = t_node.child(tag.c_str());
            if (!t_node) {
                return {};
            }
        }

        return t_node;
    }

    // Fetch all child elements of a tag name below a path list
    // children_by_path({ "root", "thing1" }, "child");
    std::vector<pugi::xml_node> xml::children_by_path(
        std::initializer_list<std::string> path,
        const std::string& child_tag) {
        std::vector<pugi::xml_node> out;
        pugi::xml_node parent = node_by_path(path);
        if (!parent) {
            return out;
        }

        for (pugi::xml_node c : parent.children(child_tag.c_str())) {
            out.push_back(c);
        }
        return out;
    }

    pugi::xml_node xml::find_node_by_attribute(
        const std::string& tag, 
        const std::string& attr_name, 
        const std::string& attr_val) {
        std::string xpath = "//" + tag + "[@" + attr_name;
        if (!attr_val.empty()) {
            xpath += "='" + attr_val + "'";
        }
        xpath += "]";

        pugi::xpath_node_set nodes = xml_doc().select_nodes(xpath.c_str());
        return nodes.empty() ? pugi::xml_node() : nodes.first().node();
    }

    const std::string xml::default_dir() const {
        return "confs";
    }

    pugi::xml_document& xml::xml_doc() {
        return xml_doc_;
    }
    
    std::filesystem::path xml::full_path() {
        return full_path_;
    }
    
    std::mutex& xml::write_mutex() {
        return write_mutex_;
    }
    
    void xml::set_xml_doc(std::string path) {
        xml_doc().load_file(path.c_str());
    }
    
}
