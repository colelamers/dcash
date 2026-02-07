module helper.xml;

// todo; move these into functions when built up
static import dxml.dom;
static import dxml.parser;
static import dxml.util;
static import dxml.writer;
static import std.file;
static import helper.app_path;
static import std.path;

// for GC reasons you should struct this at some point
class Xml {
public:
    this() {
        this.fullPath_ = std.path.buildPath(getProjectPath(), this.defaultDir_);
        if (!std.file.exists(this.fullPath_)) {
            helper.app_path.createFile(this.fullPath_);
        }
        loadXml();
    }
    
    this(string fullyQualifiedPath) {
        this.fullPath_ = fullyQualifiedPath;
        if (!std.file.exists(this.fullPath_)) {
            helper.app_path.createFile(this.fullPath_);
        }
        loadXml();
    }
private:
    enum string fileType = ".xml"; // compile-time constant
    enum string defaultDir_ = "confs"; // compile-time constant
    string fullPath_;
    string docText_;
    dxml.parser.EntityRange!(xmlConfig, string) xml_;
    auto x = 0;
    string getDefaulConfig(string configDirName) {
        
    }
    
    void loadXml() {
        // Basically read file once. Could become expensive space-wise
        // so may want to change this in the future.
        this.docText_ = std.file.readText(this.fullPath_);
        // Effectively the same thing as 
        // > dxml.parser.simpleXml
        // but I want to be explicit
        enum Config xmlConfig = makeConfig(
            SkipComments.yes,
            SkipPI.yes,
            SplitEmpty.yes,
            ThrowOnEntityRef.yes
        );
        xml_ = parseXML(xmlConfig, this.docText_);
    }
    
    string loadDefault() {

    }
   
}
