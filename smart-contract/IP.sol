// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract IntellectualPropertySystem {
    enum Role {
        Admin,
        User
    }

    struct Patent {
        uint64 applicationNumber;
        uint64 patentNumber;
        uint applicationDate;
        uint publicationDate;
        uint deniedAt; // Field for storing denied date if denied
        string IPC_Classification;
        string applicant;
        string inventors;
        string title;
        string fileIpfsHash; // Field for storing the uploaded file's IPFS hash.
        string fileName; // Field for storing the uploaded file's name.
    }

    Role public admin;
    address public owner;

    mapping(address => Role) public roles; // maps each address to its corrsponding role
    uint64 public ctrApplicationNumber; // no. of patent applications
    uint64 public ctrPatentNumber; // no. of granted patents
    mapping(uint64 => bool) public isPatentAppliedFor; // patent application filed for application number
    mapping(uint64 => bool) public isPatentGranted; // patent granted for a specific appplication number
    mapping(uint64 => bool) public isPatentDenied; // mapping for checking if patent has already been denied
    mapping(uint64 => uint) public appliedIndex; // application number with index of patent application
    mapping(uint64 => uint) public grantedIndex; // application number with index of granted patent
    mapping(uint64 => uint) public deniedIndex; // application number with index of denied patent
    mapping(bytes32 => bool) public hasBeenApplied; // hash patent applciation (applied or not)
    Patent[] public appliedPatents; // list of patent applications
    Patent[] public grantedPatents; // list of granted patents
    Patent[] public deniedPatents; // list of denied patents

    modifier onlyAdmin() {
        require(
            roles[msg.sender] == Role.Admin,
            "Only admin can access this function"
        ); // access control
        _;
    }

    // sets deployer of the contract as admin (default)
    constructor() {
        owner = msg.sender; // owner as deployer of contract
        admin = Role.Admin;
        roles[msg.sender] = admin; // initialize admin with address of the account that deployed the contract
    }

    function getRole(address _account) external view returns (uint256) {
        if (_account == owner) {
            return 1;
        } else {
            return 2;
        }
    }

    // Patent Application
    function applyForPatent(
        string memory _IPC_Classification,
        string memory _applicant,
        string memory _inventors,
        string memory _title,
        string memory _fileIpfsHash, // Parameter to pass the value for `fileIpfsHash` field.
        string memory _fileName // Parameter to pass the value for `fileName` field.
    ) external {
        require(
            !hasBeenApplied[keccak256(abi.encodePacked(msg.sender, _title))],
            "This application has already been filed"
        );

        Patent memory newPatent = Patent(
            ctrApplicationNumber, // unique applciation number to the new application
            0, // patent numnber
            block.timestamp,
            0, // publication date
            0, // placeholder for date denied
            _IPC_Classification,
            _applicant,
            _inventors,
            _title,
            _fileIpfsHash, // Append the value from `_fileIpfsHash` param.
            _fileName // Append the value from `_fileName` param.
        );

        appliedPatents.push(newPatent); // add new patents in appliedPatenets array
        hasBeenApplied[keccak256(abi.encodePacked(msg.sender, _title))] = true; // hash of patent app (mark as filed)
        appliedIndex[ctrApplicationNumber] = appliedPatents.length - 1; // records index of new patent
        isPatentAppliedFor[ctrApplicationNumber] = true; // app number already used
        ctrApplicationNumber++;
    }

    // Grant Patent
    function grantPatent(uint64 _applicationNumber) external onlyAdmin {
        require(
            isPatentAppliedFor[_applicationNumber],
            "Application does not exist"
        );
        require(
            !isPatentGranted[_applicationNumber],
            "Patent has already been granted"
        );

        appliedPatents[appliedIndex[_applicationNumber]]
            .patentNumber = ctrPatentNumber; // unique patent number
        appliedPatents[appliedIndex[_applicationNumber]].publicationDate = block
            .timestamp; // current timestamp
        grantedPatents.push(appliedPatents[appliedIndex[_applicationNumber]]);
        grantedIndex[_applicationNumber] = grantedPatents.length - 1; // records ht index of the newly granted patent
        isPatentGranted[_applicationNumber] = true; // updates isPatentGranted mapping
        ctrPatentNumber++;

        // Remove the granted patent from the appliedPatents array
        removeAppliedPatent(_applicationNumber);
    }

    // Deny Patent
    function denyPatent(uint64 _applicationNumber) external onlyAdmin {
        // Check if the application exists & available to deny
        require(
            isPatentAppliedFor[_applicationNumber],
            "Application does not exist"
        );
        // Chcek if the application is already denied
        require(
            !isPatentDenied[_applicationNumber],
            "Patent has already been denied"
        );

        appliedPatents[appliedIndex[_applicationNumber]].deniedAt = block
            .timestamp; // store the current time for date denied
        deniedPatents.push(appliedPatents[appliedIndex[_applicationNumber]]);
        deniedIndex[_applicationNumber] = deniedPatents.length - 1; // records the index of the newly denied patent
        isPatentDenied[_applicationNumber] = true; // updates isPatentDenied mapping with the newly denied patent's application-number

        // Remove the granted patent from the appliedPatents array
        removeAppliedPatent(_applicationNumber);
    }

    // Function to remove a patent in appliedPatents[]
    function removeAppliedPatent(uint64 applicationNumber) internal {
        uint index = appliedIndex[applicationNumber];
        require(index < appliedPatents.length, "Index out of bounds");

        // Swap the element to delete with the last element
        appliedPatents[index] = appliedPatents[appliedPatents.length - 1];

        // Update the index of the last element
        appliedIndex[appliedPatents[index].applicationNumber] = index;

        // Remove the last element
        appliedPatents.pop();
    }

    // Check Grant Status
    function checkGrantStatus(
        uint64 _applicationNumber
    ) external view returns (bool) {
        return isPatentGranted[_applicationNumber];
    }

    // View Application
    function viewApplication(
        uint64 _applicationNumber
    ) external view returns (Patent memory) {
        require(
            isPatentAppliedFor[_applicationNumber],
            "Application does not exist"
        );
        return appliedPatents[appliedIndex[_applicationNumber]];
    }

    // View Patent
    function viewPatent(
        uint64 _applicationNumber
    ) external view returns (Patent memory) {
        require(
            isPatentGranted[_applicationNumber],
            "Application has not been granted patent status"
        );
        return grantedPatents[grantedIndex[_applicationNumber]];
    }

    // Get All Applied Patents
    function getAllAppliedPatents() public view returns (uint256) {
        return appliedPatents.length;
    }

    // Get All Granted Patents
    function getAllGrantedPatents() public view returns (uint256) {
        return grantedPatents.length;
    }

    // Get All Denied Patents
    function getAllDeniedPatents() public view returns (uint256) {
        return deniedPatents.length;
    }
}
