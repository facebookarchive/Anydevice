## Cloud Code Setup

#### Setting Your App

From the same directory as this readme, type in `parse new .` and specify the 
app which you will host AnyDevice. For more information, see the [Cloud Code
Guide](https://parse.com/docs/cloud_code_guide#clt).

#### Using Your Own Model Data

The iOS and Android AnyDevice applications assume the existence of a `Model`
object for each supported hardware model. Therefore, when setting up your app,
you must create the `Model` class and populate it with initial
data. For example, to support the CC3200, one of the following methods can be
used:

##### Bash Script Import

If you can run a bash script, the [model_import.sh](data/model_import.sh) script
located in the `data` folder will automatically create a `Model` entry for the CC3200.
We want a `Model` to
be only public read (private write) since it is used by all users for that app.
Since a `Model` entry has an `icon` field, the image you want to use must be
supplied as an argument to the script. A default icon for the CC3200 is included
in the same folder and can be used as shown below:

```bash
./model_import.sh cc3200.png YOUR_REST_API_KEY
```

##### Manual Import

1. Go to your [Dashboard](https://parse.com/apps) in Parse.

2. Go to your application's Data browser and click on the 'Import' button on the
left side menu.

3. Upload the [Model.json](data/Model.json) file and make sure the 'Collection
Name' is set to 'Model'. Click on 'Finish Import'.

4. Once the upload is complete, find the `Model` class and click on the 'Col +'
button to add a new column. Select the type 'File' and type the column name
'icon'. Click on 'Create Column'.

5. Upload an icon for the hardware model created in step 3. For the CC3200, the
default icon is provided [here](data/cc3200.png). You can upload any icon
of your choice if you wish.
