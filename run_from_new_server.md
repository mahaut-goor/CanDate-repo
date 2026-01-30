# 💻 Installation from a distant server 

> (this will be improved in the next days)

1. **Clone the repository**

   ```bash
   git clone https://github.com/mahaut-goor/CanDate-repo.git
   ```

2. **Create the Conda environment**

   ```bash
   cd /path/to/CanDate-repo
   conda env create -f ./data/candate.yaml
   conda activate candate
   ```

3. **Modify beast module**

Modify this file ./beast_tip_dating_module

Change the path on this line:
    ```bash
    prepend-path PATH /dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/conda_env/beast_tip_dating/bin/
    ```
with the path of the conda env /bins you just created

4. **Modify config file**

Modify this file ./popgen48-beast_tip_dating/conf/lrz_cm4.config

Change the path to the module
   ```bash
   beforeScript = 'module load /dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/modules/beast_tip_dating'
```

Change the path to the conda env
   
   ```bash
    LD_LIBRARY_PATH = "/dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/conda_env/beast_tip_dating/lib:${System.getenv('LD_LIBRARY_PATH')}"
```

Change the path to the latest version of beast installed on your server

   ```bash
    PATH= "/dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/beast/bin:\$PATH"
```

 !! Don’t change the config log name (keep lrz_cm4.config)