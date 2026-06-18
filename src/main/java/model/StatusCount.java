package model;

/** Aggregate count of reports for a given status. */
public class StatusCount {

    private String status;
    private int total;

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public int getTotal() {
        return total;
    }
    public void setTotal(int total) {
        this.total = total;
    }
}
